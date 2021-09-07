---
title: "4.3 Resource hooks"
weight: 43
sectionnumber: 4.3
---

In this lab you are going to learn about [resource hooks](https://argoproj.github.io/argo-cd/user-guide/resource_hooks/).


## Resource hooks

Hooks allow to run scripts before, during and after the Argo CD **sync** operation. They give you more control over the sync process. They can, e.g., also run when the sync operation fails. The concept is very similar to the concept of [Helm hooks](https://helm.sh/docs/topics/charts_hooks/#the-available-hooks).

Some examples when hooks can be useful:

* `PreSync` hook: Upgrading a database, performing a migration before deploying a new version of the application
* `PostSync` hook: Run integration, smoke and other tests after the deployment to verify its status
* `Sync` hook: Allows to run more complex deployment strategies, e.g., blue-green or canary deployments
* `SyncFail` hook: Clean up a failed deployment

Hooks are annotated `argocd.argoproj.io/hook: <hook>` Kubernetes resources in the source repository, which Argo CD will apply during the sync operation.

A `PreSync` hook to run a database migration might therefore look like this:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  generateName: schema-migrate-
  annotations:
    argocd.argoproj.io/hook: PreSync
...
```

It's basically a [Kubernetes Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/) which starts a Pod that executes some sort of code.

{{% alert  color="primary" title="Note" %}}
Named hooks (i.e. ones with `/metadata/name`) will only be created once. If you want a hook to be re-created each time, either use BeforeHookCreation policy or `/metadata/generateName`.
{{% /alert %}}

{{% alert  color="primary" title="Note" %}}
Hooks are not run during a [selective sync](https://argoproj.github.io/argo-cd/user-guide/selective_sync/).
{{% /alert %}}


### Hook deletion policies

The hook deletion policy defines when a hook should be deleted. It's also configured with an annotation `argocd.argoproj.io/hook-delete-policy` on the hook resource.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  generateName: schema-migrate-
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
...
```

* `HookSucceeded`: Will be deleted after the hook had succeeded
* `HookFailed`: Will be deleted after a hook had failed
* `BeforeHookCreation`: Any hook resource will be deleted before a new one is created


## Task {{% param sectionnumber %}}.1: Hook example

In this task we're going to deploy an [example](https://github.com/acend/argocd-training-examples/tree/master/pre-post-sync-hook) which has `pre` and `post` hooks.

Create the new application `argo-hook-+username+` with the following command. It will create a service, a deployment and two hooks as soon as the application is synced.

* PreSync: Before the Job
* Sync: Deployment with name `pre-post-sync-hook`
* PostSync: After the Job

```bash
argocd app create argo-hook-+username+ --repo https://{{% param giteaUrl %}}/<github username>/argocd-training-examples.git --path 'pre-post-sync-hook' --dest-server https://kubernetes.default.svc --dest-namespace +username+
```

Sync the application:

{{% details title="Hint" %}}
```bash
argocd app sync argo-hook-+username+
```
{{% /details %}}

And verify the deployment:

```bash
oc get pod --namespace +username+ --watch
```

If you're more comfortable with it, you can also check the status in the respective web interfaces.


## Task {{% param sectionnumber %}}.2: Post-hook curl (optional)

Alter the post sync hook command from `sleep` to `curl https://acend.ch` (could be used to, e.g., send a notification to a chat channel).
The curl command is not available in the minimal `quay.io/acend/example-web-go` image. Use `quay.io/acend/example-web-python` or another image with curl installed.

Edit the hook in `argocd-training-examples/pre-post-sync-hook/post-sync-job.yaml` accordingly, commit and push the changes and trigger the sync operation.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: after
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
      - name: sleep
        image: quay.io/acend/example-web-python
        command:
        - 'bash'
        - '-eo'
        - 'pipefail'
        - '-c'
        - >
          curl https://acend.ch
      restartPolicy: Never
  backoffLimit: 0
```


## Task {{% param sectionnumber %}}.3: Delete the application

Delete the application after you've explored the Argo CD Resources and the managed Kubernetes resources.

{{% details title="Hint" %}}
```bash
argocd app delete argo-hook-+username+
```
{{% /details %}}
