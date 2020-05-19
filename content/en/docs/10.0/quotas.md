---
title: "10.5 Quotas and limit ranges"
weight: 105
---

FIXMEs:

- [x] Introduction to quotas and description of lab
- [x] Explanation of what types of quotas exist
- [x] Explanation and common reason for default LimitRanges

- [ ] Task: Create namespace with Resource Quotas and LimitRange
- [ ] Task: Create a Deployment without requests and limits, analyse problems with too 
- [ ] Task: Create a Deployment with requests too high to fit into Quota

---

In this lab we are going to look at resource quotas and limit ranges. As Kubernetes users we are most certainly going to encounter the limiting effects that quotas and limit ranges impose.


## Resource quotas

Resource quotas among other things limit the amount of resources pods can use in a namespace. They can also be used to limit the total number of a certain resource type in a namespace. In more detail, there are these kinds of quotas:

- _Compute resource quotas_ can be used to limit the amount of memory and CPU
- _Storage resource quotas_ can be used to limit the total amount of storage and the number of PersistentVolumeClaims, generally or specific to a StorageClass
- _Object count quotas_ can be used to limit the number of a certain resource type such as Services, Pods or Secrets

Defining resource quotas makes sense e.g. when the cluster administrators want to have better control over consumed resources. A typical use case are public offerings where users pay for a certain guaranteed amount of resources which must not be exceeded.

In order to check for defined quotas in your namespace, simply see if there are any of type ResourceQuota:

```bash
kubectl get resourcequota
```

To show in detail what kinds of limits the quota imposes:

```bash
kubectl describe resourcequota <quota-name> -n <namespace>
```

For more details, have look into [Kubernetes' documentation about resource quotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/#requests-vs-limits).


## Requests and limits

As we've already seen, compute resource quotas limit the amount of memory and CPU we can use e.g. in a Pod. Only defining a quota however is not going to have an effect on Pods that don't define the amount of resources they want to use.  This is where the concept of limits and requests comes into play.

Limits and requests on a Pod, or rather on a Container in a Pod, define how much memory and CPU this Container wants to consume at least (request) and at most (limit). Requests mean that the Container will be guaranteed to get at least this amount of resources, limits represent the upper boundary which can not be crossed. Defining these values helps Kubernetes in determining on which Node to schedule the Pod, because it knows how much resources should be available for it.

{{% alert title="Note" color="warning" %}}
Containers using more CPU time than what their limit allows will be throttled.
Containers using more memory than what they are allowed to use will be killed.
{{% /alert %}}

Defining limits and requests on a Pod that has one Container looks like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lr-demo
  namespace: lr-example
spec:
  containers:
  - name: lr-demo-ctr
    image: nginx
    resources:
      limits:
        memory: "200Mi"
        cpu: "700m"
      requests:
        memory: "200Mi"
        cpu: "700m"
```

You can see the familiar binary unit "Mi" is used for the memory value. Other binary ("Gi", "Ki", ...) or decimal units ("M", "G", "K", ...) can be used as well.

The CPU value is denoted as "m". "m" stands for _milliCPU_ or sometimes also referred to as _milliCores_ where 1000m is equal to one core/vCPU/hyperthread.


### Quality of Service

Setting limits and requests on Containers has yet another effect: It might change the Pod's _Quality of Service_ class. There are three such _QoS_ classes:

- _Guaranteed_
- _Burstable_
- _BestEffort_

The Guaranteed QoS class is applied to Pods that define both limits and requests for both memory and CPU resources on all their Containers. The most important part is that each request has the same value as the limit.
Pods that belong to this QoS class will never be killed by the scheduler because of resources running out on a Node.

{{% alert title="Note" color="warning" %}}
If a Container only defines its limits, Kubernetes automatically assigns a request that matches the limit.
{{% /alert %}}

The Burstable QoS class means that limits and requests on a Container are set but they are of a different amount. It is enough to define limits and requests on one Container of a Pod even though there might be more and it also only has to define limits and requests on memory or CPU, not necessarily both.

The BestEffort QoS class applies to Pods that do not define any limits and requests at all on any Containers.
As its class name suggests, these are the kinds of Pods that will be killed by the scheduler first if a Node runs out of memory or CPU. As you might have already guessed by now, if there are no BestEffort QoS Pods, the scheduler will begin to kill Pods belonging to the class of _Burstable_. A Node hosting only Pods of class Guaranteed will (theoretically) never run out of resources.

For more examples have a look at the [Kubernetes documentation about Quality of Service](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/).


## LimitRanges

As you now know what limits and requests are, we can come back to the statement made above:
>As we've already seen, compute resource quotas limit the amount of memory and CPU we can use e.g. in a Pod. Only defining a quota however is not going to have an effect on Pods that don't define the amount of resources they want to use.  This is where the concept of limits and requests comes into play.

So if a cluster administrator wanted to make sure that every Pod in his cluster counted against the compute resource quota, the administrator would have to have a way of defining some kind of default limits and requests that were applied if none were defined in the Containers.
This is exactly what _LimitRanges_ are for.

Quoting the [Kubernetes documentation](https://kubernetes.io/docs/concepts/policy/limit-range/), LimitRanges can be used to:

- Enforce minimum and maximum compute resources usage per Pod or Container in a namespace
- Enforce minimum and maximum storage request per PersistentVolumeClaim in a namespace
- Enforce a ratio between request and limit for a resource in a namespace
- Set default request/limit for compute resources in a namespace and automatically inject them to Containers at runtime

If for example a Container did not define any requests or limits and there was a LimitRange defining default values, these default values would be used when deploying said Container. However, as soon as limits or requests were defined, the default values would no longer be applied.

The possibility of enforcing minimum and maximum resources and defining resource quotas per Namespace allows for many combinations of resource control.


## Task 1: Namespace

{{< onlyWhen rancher >}}
Make sure you're logged in to the cluster. Choose the appropriate cluster, click on __Projects/Namespaces__ and then click on __Add Namespace__. 

Choose a name for your Namespace in the form of <yourname>-quota-lab, expand the __Container Default Resource Limit__ view and set the following values:

- __CPU Limit__: 100
- __CPU Reservation__: 10
- __Memory Limit__: 32
- __Memory Reservation__: 16

![Quota lab namespace creation](create_quotalab_namespace.png)

Finally, click on __Create__.
{{< /onlyWhen >}}

Check that your quota-lab Namespace contains the LimitRange:

```bash
kubectl describe limitrange --namespace <yourname>-quota-lab
```

Above command should output this (name and namespace will vary):

```bash
Name:       ce01a1b6-a162-479d-847c-4821255cc6db
Namespace:  eltony-quota-lab
Type        Resource  Min  Max  Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---  ---  ---------------  -------------  -----------------------
Container   memory    -    -    16Mi             32Mi           -
Container   cpu       -    -    10m              100m           -
```


Check that a Quota exists in your Namespace:

```bash
kubectl describe quota --namespace <yourname>-quota-lab
```

Above command should output this (name and namespace will vary):

```bash
Name:       lab-quota
Namespace:  eltony-quota-lab
Resource    Used  Hard
--------    ----  ----
cpu         0     100m
memory      0     100Mi
```


## Task 2: Default memory limit

Create a Pod using the polinux/stress image:

```bash
kubectl run stress2much --image=polinux/stress --namespace <yourname>-quota-lab --command -- stress --vm 1 --vm-bytes 85M --vm-hang 1
```

{{% alert title="Note" color="warning" %}}
You have to actively terminate the following command pressing Ctrl+P on your keyboard.
{{% /alert %}}

Watch the Pod's creation with:

```bash
kubectl get pods --watch --namespace <yourname>-quota-lab
```

You should see something like the following:

```bash
NAME          READY   STATUS              RESTARTS   AGE
stress2much   0/1     ContainerCreating   0          1s
stress2much   0/1     ContainerCreating   0          2s
stress2much   0/1     OOMKilled           0          5s
stress2much   1/1     Running             1          7s
stress2much   0/1     OOMKilled           1          9s
stress2much   0/1     CrashLoopBackOff    1          20s
```

The `stress2much` Pod was OOM (out of memory) killed. We can see this in the `STATUS` field. Another way to find out why a Pod was killed is by checking its status. Output at the Pod's yaml definition:

```bash
kubectl get pod stress2much --namespace <yourname>-quota-lab
```

Near the end of the output you can find the relevant status part:

```yaml
  containerStatuses:
  - containerID: docker://da2473f1c8ccdffbb824d03689e9fe738ed689853e9c2643c37f206d10f93a73
    image: polinux/stress:latest
    lastState:
      terminated:
        [...]
        reason: OOMKilled
        [...]
```

So let's look at the numbers to verify the Container really had too little memory. We started the `stress` command using parameter `--vm-bytes 85M` which means the process wants to allocate 85 megabytes of memory. Again looking at the Pod's yaml definition with:


```bash
kubectl get pod stress2much -o yaml --namespace <yourname>-quota-lab
```

reveals the following values:

```yaml
[...]
    resources:
      limits:
        cpu: 100m
        memory: 32Mi
      requests:
        cpu: 10m
        memory: 16Mi
[...]
```

These are the values from the LimitRange and the defined limit of 32 megabytes of memory prevents the `stress` process of ever allocating the desired 85 megabytes.

Let's fix this by recreating the Pod and explicitly setting the memory request to 85 megabytes:

```bash
kubectl delete pod stress --namespace <yourname>-quota-lab
kubectl run stress --image=polinux/stress --limits=memory=100Mi --requests=memory=85Mi --namespace <yourname>-quota-lab --command -- stress --vm 1 --vm-bytes 85M --vm-hang 1
```

{{% alert title="Note" color="warning" %}}
Remember, if you'd only set the limit, the request would be set to the same value.
{{% /alert %}}

You should now see that the Pod is successfully running:

```bash
NAME     READY   STATUS    RESTARTS   AGE
stress   1/1     Running   0          25s
```


## Task 3: Hitting the quota

Create another Pod, again using the polinux/stress image. This time our application is less demanding and only needs 10 megabytes of memory (`--vm-bytes 10M`):

```bash
kubectl run overbooked --image=polinux/stress --namespace <yourname>-quota-lab --command -- stress --vm 1 --vm-bytes 10M --vm-hang 1
```

We are immediately confronted with an error message:

```bash
Error from server (Forbidden): pods "overbooked" is forbidden: exceeded quota: lab-quota, requested: memory=16Mi, used: memory=85Mi, limited: memory=100Mi
```

The default request value of 16 megabytes of memory that was automatically set on the Pod lets us hit the quota which in turn prevents us from creating the Pod.

Let's have a closer look at the quota with:

```bash
kubectl get quota -o yaml --namespace <yourname>-quota-lab
```

which should output the following yaml definition:

```yaml
[...]
  status:
    hard:
      cpu: 100m
      memory: 100Mi
    used:
      cpu: 20m
      memory: 80Mi
[...]
```

The most interesting part is the quota's status which reveals that we cannot use more than 100 megabytes of memory and that 80 megabytes are already used.

Fortunately our application can live with less memory than what the LimitRange sets. Let's set the request to the required 10 megabytes:

```bash
kubectl run overbooked --image=polinux/stress --limits=memory=16Mi --requests=memory=10Mi --namespace ba-k8s-techlab-quotas --command -- stress --vm 1 --vm-bytes 10M --vm-hang 1
```

Even though the limits of both Pods combined overstretch the quota, the requests do not and so the Pods are allowed to run.