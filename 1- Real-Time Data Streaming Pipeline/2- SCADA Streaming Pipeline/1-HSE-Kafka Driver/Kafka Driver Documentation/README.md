# Merge Approval Guidelines

Merge requests to master have to be accepted by 2 approvers prior to the merge taking place, on a fast-forward only fashion. Approvers will only aprove a merge request if the conditions below are met:

## Work Tracking Rules
- Each topic/problem has a single commit. Intermediate commits are not accepted (use rebase squash to transform multiple commits into one)
- Each commit mesage references a JIRA ticket

## Repository Guidelines
- Folder names are CapitalizedCamelCase
- File names are_like_this.extension
- Documentation is placed on the appropriate folder
- Images are placed in /imgs in the releavant folder

## Documentation Quality
- Documentation is clear, complete and concise 
- No speeling mistakakes 

# Testing documentation

In order to test your documentation a docker-compose file is included in this project that will automatically create an mkdocs website with the content inside the root of this repository - please note that you need Docker installed on your machine for this to work. 

To launch a server with your modifications open a terminal on the root of this repository and type

```
docker-compose build
docker-compose up
```

Your test documentation will be available at 

> http://localhost:8000