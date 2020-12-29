# CHANGEME Training

CHANGEME Training Description


## Content Sections

The training content resides within the [content](content) directory.

The main part are the labs, which can be found at [content/en/docs](content/en/docs).


## Hugo

This site is built using the static page generator [Hugo](https://gohugo.io/).

The page uses the [docsy theme](https://github.com/google/docsy) which is included as a Git Submodule.
Docsy is being enhanced using [docsy-plus](https://github.com/puzzle/docsy-plus/) as well as
[docsy-acend](https://github.com/puzzle/docsy-acend/) and [docsy-puzzle](https://github.com/puzzle/docsy-puzzle/)
for brand specific settings.

After cloning the main repo, you need to initialize the submodule like this:

```bash
git submodule update --init --recursive
```

The default configuration uses the acend setup from [config/_default](config/_default/config.toml).
Alternatively you can use the Puzzle setup from [config/puzzle](config/puzzle/config.toml), which is enabled with
`--environment puzzle`.


### Docsy theme usage

* [Official docsy documentation](https://www.docsy.dev/docs/)
* [Docsy Plus](https://github.com/puzzle/docsy-plus/)


### Update submodules for theme updates

Run the following command to update all submodules with their newest upstream version:

```bash
git submodule update --remote
```


## Build using Docker

Build the image:

```bash
docker build <--build-arg HUGO_ENV=...> -t acend/changeme-training .
```

Run it locally:

```bash
docker run -i -p 8080:8080 acend/changeme-training
```


## How to develop locally

To develop locally we don't want to rebuild the entire container image every time something changed, and it is also important to use the same hugo versions like in production.
We simply mount the working directory into a running container, where hugo is started in the server mode.

```bash
docker run --rm --interactive --publish 8080:8080 -v $(pwd):/opt/app/src -w /opt/app/src acend/hugo:<version-in-dockerfile> hugo server -p 8080 --bind 0.0.0.0
```


## Linting of Markdown content

Markdown files are linted with <https://github.com/DavidAnson/markdownlint>.
Custom rules are in `.markdownlint.json`.
There's a GitHub Action `.github/workflows/markdownlint.yaml` for CI.
For local checks, you can either use Visual Studio Code with the corresponding extension, or the command line like this:

```shell script
npm install
node_modules/.bin/markdownlint content
```


## Contributions

If you find errors, bugs or missing information please help us improve and have a look at the [Contribution Guide](CONTRIBUTING.md).
