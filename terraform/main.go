package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"slices"
	"strings"

	"github.com/alessio/shellescape"
	"github.com/melbahja/goph"
	"golang.org/x/crypto/ssh"
)

// exit without a stacktrace
func exit(reason string, args ...any) {
	fmt.Printf(reason+"\n", args...)
	os.Exit(1)
}

// models an outputs.json key=val
type Output struct {
	key   string
	value any
}

// wrap `goph.Client` so we can add some methods of our own.
type Client struct {
	*goph.Client
}

// like `goph.Client.Run`, but command is executed as `username` using `sudo -u`.
func (c *Client) RunAs(username string, cmd string) ([]byte, error) {
	esc := shellescape.Quote(cmd)
	final_cmd := fmt.Sprintf("sudo -u %s /bin/bash -c %s", username, esc)
	slog.Info("running command", "as", username, "cmd", cmd) //, "final", final_cmd)
	return c.Run(final_cmd)
}

// like `Client.RunAs` but each command in `script` is executed sequentially,
// exiting immediately on error.
func (c *Client) RunAllAs(username string, cmd_list []string) ([]byte, error) {
	empty_resp := []byte{}
	for _, cmd := range cmd_list {
		output, err := c.RunAs(username, cmd)
		if err != nil {
			return output, fmt.Errorf("failed to run script: %w", err)
		}
	}
	return empty_resp, nil
}

// like `goph.Client.Upload`, but file is uploaded to a temporary location first,
// then moved into place as root,
// then ownership is adjusted to `username`.
func (c *Client) UploadAs(username string, localPath string, remotePath string) ([]byte, error) {
	empty_resp := []byte{}
	var err error

	output, err := c.Run("mktemp")
	if err != nil {
		return output, fmt.Errorf("failed to create temporary file: %w", err)
	}
	remote_temp_file := strings.TrimSpace(string(output))

	slog.Info("uploading", "local", localPath, "remote", remote_temp_file)
	err = c.Upload(localPath, remote_temp_file)
	if err != nil {
		return empty_resp, err
	}

	// move file into place as root, then chown file

	output, err = c.RunAs("root", fmt.Sprintf(`mv "%s" "%s"`, remote_temp_file, remotePath))
	if err != nil {
		return output, err
	}

	output, err = c.RunAs("root", fmt.Sprintf(`chown %s:%s "%s"`, username, username, remotePath))
	if err != nil {
		return output, err
	}

	return empty_resp, nil

}

// convenience. upload local script `script_path`
// to remote location `remote_script_path`
// and execute it.
// on error, any remote output is displayed.
func (c *Client) UploadExecuteScriptAs(username string, script_path string, remote_script_path string) ([]byte, error) {
	resp, err := c.UploadAs(username, script_path, remote_script_path)
	if err != nil {
		return resp, fmt.Errorf("failed to upload script: %w", err)
	}

	output, err := c.RunAs(username, "chmod +x "+remote_script_path)
	if err != nil {
		return output, fmt.Errorf("failed to make script executable: %w", err)
	}

	output, err = c.RunAs(username, remote_script_path)
	if err != nil {
		return output, fmt.Errorf("failed to execute script: %w", err)
	}

	return output, nil
}

// given a shell `script` as a string,
// write it to a temporary file and upload it to `remote_path`
// make the script executable,
// return the output of the script and any error.
func (c *Client) RunScriptAs(username string, script string, remote_path string) ([]byte, error) {
	empty_result := []byte{}

	fh, err := os.CreateTemp(os.TempDir(), "")
	if err != nil {
		return empty_result, err
	}
	defer fh.Close()

	_, err = fh.WriteString(script)
	if err != nil {
		return empty_result, fmt.Errorf("failed to write script to temporary file: %w", err)
	}

	return c.UploadExecuteScriptAs("root", fh.Name(), remote_path)
}

func print_response(resp []byte) {
	fmt.Println("---")
	fmt.Println(string(resp))
	fmt.Println("---")
}

// ---

func upload_html(client *Client, html_dir string) ([]byte, error) {
	empty_resp := []byte{}
	dir_entry_list, err := os.ReadDir(html_dir)
	if err != nil {
		return empty_resp, err
	}

	remote_root := "/var/www/html"

	for _, dir_entry := range dir_entry_list {
		if dir_entry.IsDir() {
			continue
		}
		local_path := filepath.Join(html_dir, dir_entry.Name())
		remote_path := filepath.Join(remote_root, dir_entry.Name())
		resp, err := client.UploadAs("www-data", local_path, remote_path)
		if err != nil {
			return resp, err
		}

		// because permissions are not preserved during upload (yet?),
		// ensure those in the www-data group (like vagrant, ubuntu, caddy) can read these files.
		resp, err = client.RunAs("root", fmt.Sprintf("chmod g+r %s", remote_path))
		if err != nil {
			return resp, err
		}
	}

	return empty_resp, nil
}

// essentially the ad-hoc shell scripts you can find in `./hello-world/vagrant/`.
// those scripts rely on a shared directory being present (/vagrant) to
// access the app's config.
// no such thing with a remote VM.
func execute_app(client *Client, app_name string) ([]byte, error) {

	empty_resp := []byte{}
	root, _ := filepath.Abs("..")

	switch app_name {
	case "nginx":
		output, err := client.RunAllAs("root", []string{
			"apt install nginx -y",
			"systemctl enable nginx",
			"rm -f /etc/nginx/sites-enabled/default",
			"chown -R www-data:www-data /var/www/*",
			"usermod -aG www-data ubuntu",
		})
		if err != nil {
			return output, err
		}

		nginx_conf := filepath.Join(root, "nginx", "default.conf")
		remote_nginx_conf := "/etc/nginx/sites-enabled/default.conf"
		output, err = client.UploadAs("root", nginx_conf, remote_nginx_conf)
		if err != nil {
			return output, fmt.Errorf("failed to upload nginx config: %w", err)
		}

		output, err = client.RunAllAs("root", []string{
			"nginx -t",
			"systemctl restart nginx",
		})
		if err != nil {
			return output, fmt.Errorf("failed to restart nginx: %w", err)
		}

	case "caddy":
		output, err := client.RunAllAs("root", []string{
			"/usr/bin/apt install debian-keyring debian-archive-keyring apt-transport-https curl  --assume-yes",
			"rm -f /usr/share/keyrings/caddy-stable-archive-keyring.gpg",
			"curl -1sLf https://dl.cloudsmith.io/public/caddy/stable/gpg.key | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg",
			"curl -1sLf https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt > /etc/apt/sources.list.d/caddy-stable.list",
			"apt update",
			"apt install caddy --assume-yes",
			"rm -f /etc/caddy/Caddyfile",
			// caddy doesn't create the /var/www/ dir.
			// it also doesn't run as www-data.
			// add the caddy user to www-data group.
			"mkdir -p /var/www/html",
			"chown -R www-data:www-data /var/www/*",
			"usermod -aG www-data ubuntu",
			"usermod -aG www-data caddy",
		})
		if err != nil {
			return output, err
		}

		conf := filepath.Join(root, "caddy", "Caddyfile")
		remote_conf := "/etc/caddy/Caddyfile"
		output, err = client.UploadAs("caddy", conf, remote_conf)
		if err != nil {
			return output, fmt.Errorf("failed to upload Caddy config: %w", err)
		}

		output, err = client.RunAllAs("root", []string{
			"caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile",
			"systemctl restart caddy",
		})
		if err != nil {
			return output, fmt.Errorf("failed to restart caddy: %w", err)
		}

	}

	return empty_resp, nil
}

// upload and execute the 'bootstrap' script that brings the machine into a known initial state.
func bootstrap(client *Client) ([]byte, error) {
	script_path := "../vagrant/bootstrap.sh"
	remote_script_path := "/root/bootstrap.sh"
	return client.UploadExecuteScriptAs("root", script_path, remote_script_path)
}

func main() {
	slog.Info("parsing flags")
	outputs_file_flag := flag.String("outputs-file", "", "Terraform outputs in JSON format")
	app_flag := flag.String("app", "", "app(s) to use (python, go, nginx, caddy). comma separated.")

	flag.Parse()

	// parse the --outputs
	if outputs_file_flag == nil || *outputs_file_flag == "" {
		exit("--outputs is required")
	}
	outputs_data, err := os.ReadFile(*outputs_file_flag)
	if err != nil {
		exit("failed to read bytes in outputs file: %v", err)
	}
	var json_data map[string]any
	err = json.Unmarshal(outputs_data, &json_data)
	if err != nil {
		exit("failed to parse json in outputs file")
	}

	output_map := map[string]Output{}
	for key, val := range json_data {
		val_map := val.(map[string]any) // each value is a map itself
		output_map[key] = Output{key: key, value: val_map["value"]}
	}

	public_ip_output, present := output_map["public_ip"]
	if !present {
		exit("failed to find key 'public_ip' in outputs file")
	}
	public_ip := public_ip_output.value.(string)

	port_output, present := output_map["port"]
	if !present {
		exit("failed to find key 'port' in outputs file")
	}
	port := uint(port_output.value.(float64))

	keyfile_output, present := output_map["keyfile"]
	if !present {
		exit("failed to find key 'keyfile' in outputs file")
	}
	keyfile := keyfile_output.value.(string)

	user_output, present := output_map["user"]
	if !present {
		exit("failed to find key 'user' in outputs file")
	}
	user := user_output.value.(string)

	// parse the '--app'

	if app_flag == nil || *app_flag == "" {
		exit("the --app parameter is required")
	}
	app_list := strings.Split(*app_flag, ",")
	for _, app := range app_list {
		if !slices.Contains([]string{"python", "go", "nginx", "caddy"}, app) {
			exit("the --app parameter is one of 'python', 'go', 'nginx', 'caddy'")
		}
	}

	slog.Info("using app(s)", "app-list", app_list)
	html_dir := "../html"

	// create a connection

	auth, err := goph.Key(keyfile, "")
	if err != nil {
		exit("failed to find keyfile: %v", err)
	}

	config := goph.Config{
		User:     user,
		Addr:     public_ip,
		Port:     port,
		Auth:     auth,
		Timeout:  goph.DefaultTimeout,
		Callback: ssh.InsecureIgnoreHostKey(),
	}
	slog.Info("connecting to host", "config", config)
	goph_client, err := goph.NewConn(&config)
	if err != nil {
		exit("failed to authenticate: %v", err)
	}
	defer goph_client.Close()

	client := &Client{goph_client}

	// ---

	var resp []byte

	slog.Info("running bootstrap")
	resp, err = bootstrap(client)
	if err != nil {
		print_response(resp)
		exit("failed to execute bootstrap script: %v", err)
	}

	for _, app := range app_list {
		slog.Info("executing", "app", app)
		output, err := execute_app(client, app)
		if err != nil {
			print_response(output)
			exit("failed execute app: %v", err)
		}
	}

	slog.Info("uploading html", "path", html_dir)
	resp, err = upload_html(client, html_dir)
	if err != nil {
		print_response(resp)
		exit("failed to upload html dir: %v", err)
	}

}
