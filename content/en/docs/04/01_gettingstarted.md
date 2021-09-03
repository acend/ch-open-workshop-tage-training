---
title: "4.1. Getting started"
weight: 41
sectionnumber: 4.1
---

Let's get set up for the Argo CD labs.


## Task {{% param sectionnumber %}}.1: Local Workspace Directory

During the lab, you’ll be using local files (e.g. YAML resources) which will be applied in your lab project.

Create a new folder for your \<workspace> in your Web IDE  (for example ./amm-techlab/).
You can either create it with `right-mouse-click -> New Folder` or in the Web IDE terminal `mkdir argocd-techlab`.


## Task {{% param sectionnumber %}}.2: Login on Argo CD using the argocd CLI

You can access Argo CD via Web UI (URL is provided by your trainer) or use the CLI. The Argo CD CLI Tool is already installed in the web IDE.

Since the sso login does not work inside the Web IDE for various reasons, your trainer will provide a generic local Argo CD account `hannelore` without any number.

```bash
argocd login {{% param techlabArgoCdUrl %}} --grpc-web --username hannelore
```

{{% alert title="Note" color="primary" %}}Make sure to pass the `<ARGOCD_SERVER>` without protocol e.g. `argocd.domain.com`. The `--grpc-web` parameter is necessary due to missing http 2.0 router.{{% /alert %}}


## Task {{% param sectionnumber %}}.3: Lab Setup

Most of the labs will be done inside the Kubernetes namespace with your usual username. Verify that your `kubectl` tool always uses the correct namespace:

```
kubectl --namespace <namespace>
```
