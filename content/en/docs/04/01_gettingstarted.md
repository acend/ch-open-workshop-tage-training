---
title: "4.1. Getting started"
weight: 41
sectionnumber: 4.1
---

Let's get set up for the Argo CD labs.


## Task {{% param sectionnumber %}}.1: Local workspace directory

During the lab, you’ll be using local files (e.g. YAML resources) which will be applied in your lab project.

Create a new folder for your \<workspace> in your Web IDE  (e.g. ./argocd/).
You can either create it with `right-mouse-click -> New Folder` or in the Web IDE terminal using the command `mkdir <workspace>`.


## Task {{% param sectionnumber %}}.2: Login on Argo CD using the argocd CLI

You can access Argo CD via Web UI (URL is provided by your trainer) or use the CLI. The Argo CD CLI tool is already installed in the web IDE.

```bash
argocd login {{% param techlabArgoCdUrl %}} --grpc-web --username +username+
```

{{% alert title="Note" color="primary" %}}
The `--grpc-web` parameter is necessary due to the router lacking http 2.0 functionality.
{{% /alert %}}
