# How to create an HTTPS certificate for localhost domains

This document focuses on generating the localhost SSL certificates for loading
API microservice locally, hosted on your computer, for development only.

**Do not use self-signed certificates in production !** For online certificates,
use Let's Encrypt instead
([tutorial](https://gist.github.com/cecilemuller/a26737699a7e70a7093d4dc115915de8)).

## Certificate authority (CA)

### Generate `RootCA.pem`, `RootCA.key` & `RootCA.crt`

Navigate to `~/api/rootca` folder.

```bash
    export MSYS_NO_PATHCONV=1
    cd ./packages/api/rootca
    mkdir private
    openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout private/RootCA.key -out RootCA.pem -subj "/C=US/CN=T4J-Root-CA"
    openssl x509 -outform pem -in RootCA.pem -out RootCA.crt
```

> Note that `T4J-Root-CA` is just an example, you can customize the name.

## Localhost certificate

While you can create your own domains configuration, the sample of one is
already provided for you in the root directory of the `API` folder.

### Generate `localhost.key`, `localhost.csr`, and `localhost.crt`

```bash
    openssl req -new -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.csr -subj "/C=US/ST=YourState/L=YourCity/O=Example-Certificates/CN=localhost.local"
    openssl x509 -req -sha256 -days 1024 -in localhost.csr -CA RootCA.pem -CAkey private/RootCA.key -CAcreateserial -extfile domains.ext -out localhost.crt
```

> Note that the country / state / city / name in the first command can be
> customized.

## Trust the local CA

At this point, the API website would load with a warning about self-signed
certificates. In order to get a green lock, your new local CA has to be added to
the trusted Root Certificate Authorities.

### Windows 11/10: Chrome, IE11 & Edge

Windows 11/10 recognizes `.crt` files, so you can right-click on `RootCA.crt` >
`Install` to open the import dialog.

Make sure to select **Trusted Root Certification Authorities** and confirm.

You should now get a green lock in Chrome, IE11 and Edge.

### Windows 11/10: Firefox

There are two ways to get the CA trusted in Firefox.

The simplest is to make Firefox use the Windows trusted Root CAs by going to
`about:config`, and setting `security.enterprise_roots.enabled` to `true`.

The other way is to import the certificate by going to
`about:preferences#privacy` > `Certificats` > `Import` > `RootCA.pem` > `Confirm for websites`.
