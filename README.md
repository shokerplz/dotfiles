## How to work with secrets

We're using sops-nix (https://github.com/Mic92/sops-nix). It is already added to flake so nothing needs to be done in terms of installation.

### How to create private key?

```
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

### Where private key is stored?

Private key is stored on a secure machine in ~/.config/sops/age/keys.txt


### How to add a secret for a new machine?

1. You need to acquire public key for a new machine
```
nix-shell -p ssh-to-age --run "ssh-keyscan new-machine.home | grep -i ed25519 | ssh-to-age"
```
In the output you will find a public key

2. You need to add that public key to .sops.yaml file to `keys` array. Example: &new-machine aabbb...
3. You need to add an alias of this machine (*new-machine) to `creation_rules.key_groups.age` array of a secret group that needs to be added
4. You need to run `sops updatekeys secrets/needed_secret.yaml` to update it so new public key will be added to this secret

### How to add secrets to nix configuration?

In service configuration define secret that needs to be accessed. For example in `services/cloudflare-ddns.nix`
```
sops = { secrets = { cloudflare_api_token = { sopsFile = "secrets/cloudflare.yaml" }; }; };
```
That means that cloudflare_api_token secret will be accessibe in this configuration and relative location of encrypted secret is secrets/cloudflare.yaml.

After that - secrets will be accessible via file paths, for example `config.sops.secrets.cloudflare_api_token.path` will point to a file where secret is stored in plain text.

NB: It is impossible to get secrets as strings as of now.

### How to create/edit a secret?

```
nix-shell -p sops --run "sops secrets/newsecret.yaml"
```

### FAQ

If you have encountered error:
```
failed to load age identities: failed to open file: open
/Users/admin/Library/Application Support/sops/age/keys.txt:
no such file or directory
```
Then you need to do:
```
mkdir -p  "/Users/admin/Library/Application Support/sops/age/"
ln -s ~/.config/sops/age/keys.txt "/Users/admin/Library/Application Support/sops/age/keys.txt"
```

## How to format files?

```
nix-shell -p nixfmt-rfc-style --run "nixfmt ."
```