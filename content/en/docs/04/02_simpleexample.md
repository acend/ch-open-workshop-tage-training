---
title: "4.2. Simple example"
weight: 42
sectionnumber: 4.2
---

In this lab you will learn how to deploy a simple application using Argo CD.


## Task {{% param sectionnumber %}}.1: Fork the git repository

As we are proceeding according to the GitOps principle we need some example resource manifests in a Git repository which we can edit.

You need a personal GitHub account with which you can fork the repository at [argocd-training-examples](https://github.com/acend/argocd-training-examples) to your personal account.
To fork the repository, open the [repository URL](https://github.com/acend/argocd-training-examples) in the top right of the page and click on _Fork_.

Clone the forked repository:

```bash
git clone https://github.com/<github-username>/argocd-training-examples
```

{{% alert title="Note" color="primary" %}}
We don't need to provide Git credentials because the repository is readable for non-authenticated users as well.
{{% /alert %}}

Change the working directory to the cloned repository:

```bash
cd argocd-training-examples/example-app
```

Configure the git client and verify the output:

```bash
git config user.name <your name on GitHub>
git config user.email <your email address on GitHub>
git config --local --list
```


## Task {{% param sectionnumber %}}.2: Deploying resources with Argo CD

Now we want to deploy the resource manifests contained in the cloned repository with Argo CD to demonstrate its basic features.

Deploy the resources using the following command:

```bash
argocd app create argo-+username+ --repo https://{{% param giteaUrl %}}/<github-username>/argocd-training-examples.git --path 'example-app' --dest-server https://kubernetes.default.svc --dest-namespace +username+
```

Expected output: `application 'argo-+username+' created`

{{% alert title="Note" color="primary" %}}
If you want to deploy it in a different namespace, make sure the namespace exists before syncing the app.
{{% /alert %}}

Once the application is created, you can view its status:

```bash
argocd app get argo-+username+
```

```
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          <namespace>
URL:                https://{{% param argoCdUrl %}}/applications/argo-<namespace>
Repo:               https://{{% param giteaUrl %}}/<github-username>/argocd-training-examples.git
Target:
Path:               example-app
SyncWindow:         Sync Allowed
Sync Policy:        <none>
Sync Status:        OutOfSync from  (5a6f365)
Health Status:      Missing

GROUP  KIND        NAMESPACE    NAME           STATUS     HEALTH   HOOK  MESSAGE
       Service     <namespace>  simple-example OutOfSync  Missing
apps   Deployment  <namespace>  simple-example OutOfSync  Missing
```

The application status is initially in OutOfSync state. To sync (deploy) the resource manifests, run:

```bash
argocd app sync argo-+username+
```

This command retrieves the manifests from the git repository and performs a `{{% param cliToolName %}} apply` on them.
Because all our manifests have been deployed manually before, no new rollout of them will be triggered.
But from now on, all resources are managed by Argo CD. Congrats, this was the first step in the direction of GitOps!

You should see an output similar to the following lines:

```
TIMESTAMP                  GROUP        KIND   NAMESPACE    NAME            STATUS     HEALTH        HOOK  MESSAGE
2021-03-24T14:19:16+01:00            Service   <namespace>  simple-example  OutOfSync  Missing
2021-03-24T14:19:16+01:00   apps  Deployment   <namespace>  simple-example  OutOfSync  Missing
2021-03-24T14:19:16+01:00            Service   <namespace>  simple-example  Synced     Healthy

Name:               argo-<namespace>
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          <namespace>
URL:                https://{{% param argoCdUrl %}}/applications/argo-<namespace>
Repo:               https://{{% param giteaUrl %}}/<github-username>/argocd-training-examples.git
Target:
Path:               example-app
SyncWindow:         Sync Allowed
Sync Policy:        <none>
Sync Status:        Synced to  (5a6f365)
Health Status:      Progressing

Operation:          Sync
Sync Revision:      5a6f365d8a65d1dab0761fc0d32b90f7eb480354
Phase:              Succeeded
Start:              2021-03-24 14:19:16 +0100 CET
Finished:           2021-03-24 14:19:16 +0100 CET
Duration:           0s
Message:            successfully synced (all tasks run)

GROUP  KIND        NAMESPACE    NAME            STATUS  HEALTH       HOOK  MESSAGE
       Service     <namespace>  simple-example  Synced  Healthy            service/simple-example created
apps   Deployment  <namespace>  simple-example  Synced  Progressing        deployment.apps/simple-example created
```

Check the Argo CD UI to browse the application and their components.

Application overview in unsynced and synced state:

![Application overview (unsynced state)](../app-overview-unsynced.png)
![Application overview (synced state)](../app-overview-synced.png)

Detailed view of an application in unsynced and synced state:

![Application Tree (unsynced state)](../app-tree-unsynced.png)

![Application Tree (synced state)](../app-tree-sycned.png)


## Task {{% param sectionnumber %}}.3: Automated sync policy and diff

When there is a new commit in your Git repository, the Argo CD application becomes OutOfSync. Let's assume we want to scale up our `Deployment` of the example application from 1 to 2 replicas. We will change this in the Deployment manifest.

Increase the number of replicas in your file `<workspace>/example-app/deployment.yaml` to 2.

```
{{< highlight YAML "hl_lines=6" >}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simple-example
spec:
  replicas: 2
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app: simple-example
  template:
    metadata:
      labels:
        app: simple-example
    spec:
      containers:
      - image: quay.io/acend/example-web-go
        name: simple-example
        ports:
        - containerPort: 5000
{{< / highlight >}}
```

Commit the changes and push them to the remote git repository:

```bash
git add deployment.yaml
git commit -m "Increase replicas to 2"
git push
```

{{% alert title="Note" color="primary" %}}
In order to push, you'll need to provide your credentials.

If you have two-factor authentication enabled, you first have to [create a personal access token](https://github.com/settings/tokens/new).
Fill in the **Note** field, set the desired **Expiration** and select the scope **repo** (with all its sub elements).
Scroll to the bottom of the page and click on **Generate token**.

From here on out, use this generated token as your password when pushing to your repository.
{{% /alert %}}

After a successful push you should see the following output:

```bash
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 8 threads
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 367 bytes | 367.00 KiB/s, done.
Total 4 (delta 3), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (3/3), completed with 3 local objects.
To https://{{% param giteaUrl %}}/<github-username>/argocd-training-examples.git
   5a6f365..e2d4bbf  master -> master
```

Check the state of the resources by cli:

```bash
argocd app get argo-+username+ --refresh
```

The parameter `--refresh` triggers an update against the Git repository. The repository is polled by Argo CD in a predefined interval (by default every 3 minutes). To use a synchronous workflow you can use webhooks in Git. These will trigger a synchronization in Argo CD on every push to the repository.

You will see that the Deployment is now OutOfSync:

```
Name:               argo-<namespace>
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          <namespace>
URL:                https://{{% param argoCdUrl %}}/applications/argo-<namespace>
Repo:               https://{{% param giteaUrl %}}/<github-username>/argocd-training-examples.git
Target:
Path:               example-app
SyncWindow:         Sync Allowed
Sync Policy:        <none>
Sync Status:        OutOfSync from  (e2d4bbf)
Health Status:      Healthy

GROUP  KIND        NAMESPACE    NAME            STATUS     HEALTH   HOOK  MESSAGE
       Service     <namespace>  simple-example  Synced     Healthy        service/simple-example created
apps   Deployment  <namespace>  simple-example  OutOfSync  Healthy        deployment.apps/simple-example created
```

When an application is OutOfSync then your deployed 'live state' is no longer the same as the 'target state' which is represented by the resource manifests in the Git repository. You can inspect the differences between live and target state using the `diff` subcommand:

```bash
argocd app diff argo-+username+
```

This should give you an output similar to:

```
===== apps/Deployment <namespace>/simple-example ======
101c102
<   replicas: 1
---
>   replicas: 2
```

Now open the web console of Argo CD and go to your application. The deployment `simple-example` is marked as 'OutOfSync':

![Application out-of-sync](../app-replicas-diff-overview.png)

With a click on the Deployment and then **DIFF** you will see the differences:

{{% alert title="Note" color="primary" %}}
You might want to enable the **Compact diff** toggle on the right side.
{{% /alert %}}

![Application differences](../app-replicas-diff-detail.png)

Now click **Sync** button on the top right and let the magic happen. The application will be scaled up to 2 replicas and the resources are in sync again.

Double-check the status by cli:

```bash
argocd app get argo-+username+
```

```
Name:               argo-<namespace>
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          <namespace>
URL:                https://{{% param argoCdUrl %}}/applications/argo-<namespace>
Repo:               https://{{% param giteaUrl %}}/<github-username>/argocd-training-examples.git
Target:
Path:               example-app
SyncWindow:         Sync Allowed
Sync Policy:        <none>
Sync Status:        Synced to  (e2d4bbf)
Health Status:      Healthy

GROUP  KIND        NAMESPACE    NAME            STATUS  HEALTH   HOOK  MESSAGE
       Service     <namespace>        simple-example  Synced  Healthy        service/simple-example unchanged
apps   Deployment  <namespace>        simple-example  Synced  Healthy        deployment.apps/simple-example configured
```

Argo CD can automatically sync an application when it detects differences between the desired manifests in the repository and the live state on the cluster. A benefit of automatic sync is that CI/CD pipelines no longer need direct access to the Argo CD API server to perform the deployment. Instead, the pipeline makes a commit and pushes it to the repository.

To configure automatic sync run (you could also use the UI):

```bash
argocd app set argo-+username+ --sync-policy automated
```

From now on Argo CD will automatically apply all resources to the Kubernetes cluster every time you commit to the repository.

Decrease the replicas count to 1 and push the updated manifest to remote. Wait for a few moments and check that Argo CD will scale the deployment of the example app down to 1 replica. The default polling interval is 3 minutes. If you don't want to wait you can force a refresh by clicking `Refresh` in the UI or by cli:

```bash
argocd app get argo-+username+ --refresh
```


## Task {{% param sectionnumber %}}.4: Automatic self-healing

By default, changes made to the live cluster will not trigger automatic sync. To enable automatic sync when the live cluster's state deviates from the state defined in the repository, run:

```bash
argocd app set argo-+username+ --self-heal
```

Watch the deployment `simple-example` in a separate terminal:

```bash
{{% param cliToolName %}} get deployment simple-example --watch --namespace=+username+
```

Let's scale our `simple-example` Deployment and observe what's happening:

```bash
{{% param cliToolName %}} scale deployment simple-example --replicas=3 --namespace=+username+
```

Argo CD will immediately scale back the `simple-example` Deployment to `1` replicas. You will see the desired replicas count in the watched Deployment:

```
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
simple-example   1/1     1            1           114m
simple-example   1/3     1            1           114m
simple-example   1/3     1            1           114m
simple-example   1/3     1            1           114m
simple-example   1/3     3            1           114m
simple-example   1/1     3            1           114m
simple-example   1/1     3            1           114m
simple-example   1/1     3            1           114m
simple-example   1/1     1            1           114m
```

This is a great way to enforce a strict GitOps principle. Changes which are manually made on deployed resource manifests are reverted immediately to the desired state by the Argo CD controller.


## Task {{% param sectionnumber %}}.5: Pruning

You probably asked yourself how you can delete deployed resources on the container platform. Argo CD can be configured to delete resources that no longer exist in the repository.

First delete the file `svc.yaml` from the repository and push the changes:

```bash
git rm svc.yaml
git add --all && git commit -m 'Removes service' && git push
```

Check the status of the application with

```bash
argocd app get argo-+username+ --refresh
```

You can see that even with auto-sync and self-healing enabled the status is still OutOfSync:

```
GROUP  KIND        NAMESPACE    NAME            STATUS     HEALTH   HOOK  MESSAGE
apps   Deployment  <namespace>  simple-example  Synced     Healthy        deployment.apps/simple-exampleconfigured
       Service     <namespace>  simple-example  OutOfSync  Healthy
```

Now enable the auto-pruning explicitly:

```bash
argocd app set argo-+username+ --auto-prune
```

Recheck the status again

```bash
argocd app get argo-+username+ --refresh
```

```
GROUP  KIND        NAMESPACE    NAME            STATUS     HEALTH   HOOK  MESSAGE
       Service     <namespace>  simple-example  Succeeded  Pruned         pruned
apps   Deployment  <namespace>  simple-example  Synced     Healthy        deployment.apps/simple-example unchanged
```

The Service was successfully deleted by Argo CD because the manifest was removed from the repository. See the HEALTH and MESSAGE columns of the previous console output.


## Task {{% param sectionnumber %}}.6: State of Argo CD

Argo CD is largely built stateless. The configuration is persisted as native Kubernetes objects. And those are stored in _etcd_ (a key-value store to save Kubernetes' whole cluster state). There is no additional storage layer needed to run Argo CD. The Redis storage under the hood acts just as a throw-away cache and can be evicted anytime without any data loss.

The configuration changes made on Argo CD objects through the UI or by its cli tool `argocd` are reflected in updates of the Argo CD Kubernetes objects `Application` and `AppProject` in the `{{% param argoInfraNamespace %}}` namespace.

Let's list all Kubernetes objects of type `Application`:

```bash
{{% param cliToolName %}} get applications --namespace={{% param argoInfraNamespace %}}
```

```
NAME               SYNC STATUS   HEALTH STATUS
argo-+username+    Synced        Healthy
```

You will see the application which we created some chapters ago with the cli command `argocd app create...`. To see the complete configuration of the `Application` as _yaml_ use:

```bash
{{% param cliToolName %}} get application argo-+username+ --output yaml --namespace={{% param argoInfraNamespace %}}
```

You can even edit the `Application` resource with `kubectl`'s `edit` subcommand:

```bash
{{% param cliToolName %}} edit application argo-+username+ --namespace={{% param argoInfraNamespace %}}
```

This allows us to manage the Argo CD application definitions in a declarative way as well. It is a common pattern to have one Argo CD application which references many child Applications which allows us a fast bootstrapping of a whole environment or a new cluster. This pattern is well known as the [App of apps](https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) pattern.


## Task {{% param sectionnumber %}}.7: Delete the application

You can delete the Argo CD Application with the following command:

```bash
argocd application delete argo-+username+
```

This will delete the `Application` manifests of Argo CD and all created resources by this application. In our case the `Application`, `Deployment` and `Service` will be deleted.

With the flag `--cascade=false`, only the Argo CD Application will be deleted but its created Deployment and Service resources remain untouched.
