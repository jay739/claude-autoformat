# Contributing to claude-autoformat

Thanks for considering a contribution. Issues, discussions and PRs are all
welcome.

## Getting set up

```
git clone https://github.com/jay739/claude-autoformat && cd claude-autoformat
./install.sh
```

Bash + jq. The hook itself never installs formatters.

## Running the checks

```
shellcheck hooks/autoformat.sh install.sh
bash tests/smoke.sh
```

## Ground rules

- Open an issue or discussion before large changes, so effort isn't wasted.
- Keep PRs focused: one change per PR.
- New behavior needs a test where the repo has a test suite.
- CI must pass before merge.

## Licensing

By contributing you agree your contributions are licensed under the repo's
MIT license.
