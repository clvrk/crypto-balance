<div align="center">
    <h1><code>crypto-balance.sh</code></h1>
</div>

`crypto-balance.sh` is a bash-compliant shell script to fetch the current account balance from one or more exchanges and wallets.

## Getting started
```bash
chmod +x crypto-balance.sh
```

### API keys & secrets
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
### macOS status bar

## Troubleshooting
The called APIs require a precise timestamp provided in the request, therefor it is necessary to sync your system time.