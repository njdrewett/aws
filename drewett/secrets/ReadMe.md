
Access keys for AWS can be provided for CLI commands using the simple export (linux) or set (Windows) command for the Key Id And Secret
set AWS_ACCESS_KEY_ID=<yourkey>
set AWS_SECRET_ACCESS_KEY=<yourSecret>


For aws you can also use the tools aws-vault where you can specificy the profile to staore your access key and secret against.
Accessible from https://github.com/99designs/aws-vault

```aws-vault add dev```

and access those creditentials when running commands with 
```aws-vault exec <profile> -- <command> ```


