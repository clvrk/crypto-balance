<div align="center">
    <h1><code>crypto-balance.sh</code></h1>
</div>

`crypto-balance.sh` is a shell script to fetch the current account balance from one or more exchanges and wallets.

The following exchanges are currently supported: Binance\
*... pull requests for more exchanges are welcome :-)*

## Table of contents
- [Getting started](#getting-started)
- [API keys & secrets](#api-keys--secrets)
- [Use cases](#use-cases)
  - [Linux status bar (Polybar)](#linux-status-bar-polybar)
  - [macOS status bar](#macos-status-bar)
- [Troubleshooting](#troubleshooting)
  - [Syncing system time with NTP server](#syncing-system-time-with-ntp-server)
  - [Call APIs in considerate intervals](#call-apis-in-considerate-intervals)
  - [Missing dependencies](#missing-dependencies)

## Getting started
`crypto-balance.sh` requires `jq` and `bc` to be installed. Make sure these packages are installed before you proceed.

Furthermore, you'll also need a API-key file with the API-keys and secrets for each provider you intend to use. For more information, have a look at the [API keys & secrets](#api-keys--secrets) section. 

In order to be able to execute the script as a non-privileged user, give yourself execution-permission by running:
```bash
chmod +x crypto-balance.sh
```
Now, you can run the script:
```bash
sh crypto-balance.sh -p coinbase,binance -w all -c EUR --api-file ~/keys.txt
```

## API keys & secrets
To call the exchanges APIs, you need to provide API keys and secrets for each provider that you intend to use. You can generate new API keys in the account-settings of your exchange. `crypto-balance.sh` only requires access to the account-read scope, so make sure to limit the permissions accordingly.\
API keys and secrets are read from a file specified by the `--api-file` flag. Each line represents an entry in the form of a shortcode specifying the provider, followed by a comma-seperated pair of the API key and secret.
|Provider|Shortcode|
|:--     |:--      |
|Binance |`bn`     |
|Coinbase|`cb`     |

Example:
```
bn:1a2b3c,4d5e6f
cb:7g8h9i,0j1k2l
```

## Use cases
### Linux status bar (Polybar)
With a bar like [Polybar](), you can add the output of `crypto-balance.sh` to your status bar.
Simply add this to your Polybar `config`:
```bash
[module/crypto-balance]
type = custom/script
exec = sh "<path>/crypto-balance.sh" -p binance -w all -c USD -f "<path>/api-keys.txt"
interval = 5
```
and activate the module by adding `crypto-balance` to the `modules-left`, `modules-center` or `modules-right` section of your `config`.\
Make sure to adjust the paths (`<path>`) according to your system.
### macOS status bar
You can use a tool like [BitBar](https://github.com/matryer/bitbar) to run this script and write its output to the status bar.
If you're running an older release of macOS, you should [update `bash`](https://medium.com/@thechiefalone/how-to-install-bash-5-0-mac-os-ae570be6c687), however if you're running a recent release of macOS that has `zsh` as its default shell, run the following command in the same directory where `crypto-balance.sh` is located:
```bash
sed -i 's/bash/zsh/' crypto-balance.sh
```
As a quick start, choose the `extra/bitbar-plugin` directory as the plugin-folder for BitBar. Make sure to edit `crypto-balance-wrapper.sh` and append any required arguments.\
*(If you already have plugin directory, you may move the `crypto-balance-wrapper.sh` to that directory, but remember to adjust the paths in the wrapper script.*

## Troubleshooting
If something isn't working as expected, please check these steps first. However, if following these steps does not resolve your problem, please open a new issue.
### Syncing system time with NTP server
The called APIs require a precise timestamp provided in the request, therefor it is necessary to sync your system time.\
Find out more on how to sync system time on [Linux](https://wiki.archlinux.org/index.php/Systemd-timesyncd) (systemd) or [macOS](https://apple.stackexchange.com/questions/117864/how-can-i-tell-if-my-mac-is-keeping-the-clock-updated-properly/117865#117865).
### Call APIs in considerate intervals
Make sure not to spam the API backends with too frequent requests.
### Missing dependencies
As mentioned above, `jq` and `bc` is required for `crypto-balance.sh` to work.