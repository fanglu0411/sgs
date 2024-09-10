String deployIntro = r'''
### Deploy introduction

Deploy sgs service by docker, support install on macos and linux. Three containers will be created, sgs-mysql, sgs-api, sgs-web. 

After finishing deploy, your data will be stored in base path (**or your custom path**):
> Linux: `/data/docker/vol/sgs`
> Macos: `${HOME}/docker/vol/sgs`)

two sub-folder (`mysql`, `api`) will be created.

```shell
# macos
|-/Users/json/docker/vol/sgs
  |-mysql
  |-api
  
# linux  
|-/data/docker/vol/sgs
  |-mysql
  |-api
```
You need to put your origin data(`gff`,`bed`, `vcf`, `h5ad`, etc) under `api`.
''';
