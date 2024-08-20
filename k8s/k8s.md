# k8s



查看token用户：kubectl -n kubernetes-dashboard get secret



kubectl -n kubernetes-dashboard create token admin-user 获取admin的token

## 获取命令

```shell
kubectl get pod

kubectl get services -n namespaces
```

## 创建资源

```shell
kubectl create -f 文件名.yaml #创建资源

kubectl replace -f 文件名 [–force] #重建资源
```

## 修改资源

```shell
# kubectl edit <资源类型> <资源名称>

#这将打开指定 Pod 的 YAML 配置文件，允许您编辑 Pod 的配置
kubectl edit pod <pod名称>

#这将打开指定 Service 的 YAML 配置文件，允许您编辑服务的配置，如端口、负载均衡器类型等
kubectl edit service <service名称>
```

### 删除资源

```shell
#通过名称删除一个 Pod
$ kubectl delete pod <pod名称>
#删除所有符合特定标签的Pod
$ kubectl delete pod -l <标签选择器>
# 删除 pod.json 文件中定义的类型和名称的 pod
$ kubectl delete -f ./pod.json        
# 删除名为“baz”的 pod 和名为“foo”的 service
$ kubectl delete pod,service baz foo      
# 删除具有 name=myLabel 标签的 pod 和 serivce
$ kubectl delete pods,services -l name=myLabel       
# 删除具有 name=myLabel 标签的 pod 和 service，包括尚未初始化的
$ kubectl delete pods,services -l name=myLabel --include-uninitialized   
# 删除 my-ns namespace 下的所有 pod 和 serivce包
$ kubectl -n my-ns delete po,svc --all
```

## 更新资源

```shell
Kubectl apply
#用来创建或更新资源的命令。它可以接受一个或多个 YAML 或 JSON 格式的配置文件，并根据这些文件中描述的内容创建或更新相应的资源。

$ kubectl apply -f commands.yaml
#serviceaccount/tiller created
#clusterrolebinding.rbac.authorization.k8s.io/tiller created
```

## 故障排除和调试

```shell
#获取特定 Pod 的详细信息 包括 Pod 的状态、容器状态、事件等
$ kubectl describe pod <pod_name>
# 获取特定 Service 的详细信息，包括 Service 的类型、端口、目标端口等。
$kubectl describe service <service_name>
#获取特定 Deployment 的详细信息，包括副本数、更新策略、滚动更新状态等。
$kubectl describe deployment <deployment_name>


#查看 Pod 中容器的日志
$ kubectl logs <pod_name>
#如果 Pod 中有多个容器，则需要指定容器的名称
$ kubectl logs <pod_name> -c <container_name>
#实时日志流 -f 标志来实时跟踪容器的日志输出
$ kubectl logs -f <pod_name>
#指定容器的先前日志 -p 标志来指定要检索的先前日志的行数。
$ kubectl logs -p 100 <pod_name>
$ kubectl logs cherry-chart-88d49478c-dmcfv -n charts

```

















