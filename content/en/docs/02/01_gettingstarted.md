---
title: "2.1 Getting started"
weight: 21
sectionnumber: 2.1
---

In this lab, we will interact with the {{% param distroName %}} cluster for the first time.


## Task {{% param sectionnumber %}}.1: Login

Our Kubernetes cluster runs on [cloudscale.ch](https://cloudscale.ch) (a Swiss IaaS provider) and has been provisioned with [Rancher](https://rancher.com/).

In order to see the resources you are going to create via cli in a web interface, you can log in to the cluster with a Rancher user.

{{% alert title="Note" color="primary" %}}
Your trainer will provide you with the information needed to log in.
{{% /alert %}}

Log in to the Rancher web console and choose the appropriate cluster.

What's left is to log in on your webshell:
Open the URL that was provided to you in a browser.

That's it!


## Task {{% param sectionnumber %}}.2: Namespace view

A Namespace is a logical design used in Kubernetes to organize and separate your applications, Deployments, Pods, Ingresses, Services, etc. on a top-level basis. Take a look at the [Kubernetes docs](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/). Authorized users inside a namespace are able to manage those resources. Namespace names have to be unique in a cluster.

{{% onlyWhen rancher %}}
{{% alert title="Note" color="primary" %}}
Additionally, Rancher knows the concept of a [*Project*](https://rancher.com/docs/rancher/v2.x/en/cluster-admin/projects-and-namespaces/) which encapsulates multiple Namespaces.
{{% /alert %}}

In the Rancher web console choose the Project called `Training`.
Amongst others, you can see your own Namespace (`userX`) listed in this project.
Your own namespace already contains a Deployment that is responsible for running your webshell Pod.
As soon as you've created your own first resources, you'll be able to see them in this view as well.

{{% alert title="Note" color="primary" %}}
We are going to use `<namespace>` as a placeholder for your own namespace. Each time you see a `<namespace>` somewhere in a command, replace it with the name of your own namespace.
{{% /alert %}}

{{% onlyWhen mobi %}}
We use the project `kubernetes-techlab` on the `kubedev` cluster.
{{% /onlyWhen %}}

{{% /onlyWhen %}}


## Task {{% param sectionnumber %}}.3: Namespace creation

As we are working with a webshell environment, the namespace you're going to work with already exists.
However, if it didn't here's how you can find out how to do just that.

Execute the `kubectl help` command to figure out the right command:

```bash
kubectl help
```


### Solution

In order to create a new Namespace use the following command:

```bash
kubectl create namespace <namespace>
```

{{% onlyWhen rancher %}}
{{% alert title="Note" color="primary" %}}
Namespaces created via `kubectl` would have to be assigned to the correct Rancher Project in order to be visible in the Rancher web console.
{{% /alert %}}
{{% /onlyWhen %}}

{{% alert title="Note" color="primary" %}}
By using the following command, you can switch into another Namespace instead of specifying it for each `kubectl` command.

```bash
kubectl config set-context $(kubectl config current-context) --namespace <namespace>
```

Some prefer to explicitly select the Namespace for each `kubectl` command by adding `--namespace <namespace>` or `-n <namespace>`.
Others prefer helper tools like `kubens`.
{{% /alert %}}
