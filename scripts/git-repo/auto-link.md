# GitHub

## Auto link Protection Rules

This will create the auto link to Jira.

```sh
./auto-link.sh $reponame $PAT
```

PAT must have `administration:write`. [Create a repository rule set](https://docs.github.com/en/rest/repos/autolinks?apiVersion=2022-11-28#create-an-autolink-for-a-repository)
