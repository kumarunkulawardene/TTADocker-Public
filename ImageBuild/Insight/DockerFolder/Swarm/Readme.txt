How to deploy insight into swarm

1. Push Insight images to some container registry. (Azure container registry or DockerHub)


2. Place license file into G:\

3. Install docker engine on all nodes

4. Login to docker repository where insight images are located.
docker login --username <user> --password <password> <docker repository URL>

5. Open ports on all nodes

6. Initializer docker swarm on master node
docker swarm init

7. Join all other nodes to cluster using command that was printed out after master node swarm initialization

8. Create overlay network 
docker network create --driver=overlay --attachable core-infra

9. Change image paths in docker-compose.yml to published insight images paths

10. Create smb shared folder and map it too G:\ on all nodes
https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/persistent-storage

$creds = Get-Credential
New-SmbGlobalMapping -RemotePath \\<SHARED_FOLDER_PATH> -Credential $creds -LocalPath G

11. docker stack deploy --compose-file docker-compose.yml --with-registry-auth insight
(first deploy will take ~30 minutes)

12. Check services status
docker service ls

13. In case of REPLICAS 0/* check errors
docker service ps
 
NOTE: swarm service cannot be accessed by localhost url. 