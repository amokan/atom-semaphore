# Semaphore

Shows the [Semaphore](http://semaphoreapp.com) build status for the current project in the Atom status bar.

![Semaphore Preview](http://i.imgur.com/w3OqO96.png)

## Configuring

Find your authentication token for your Semaphore project.

This can be found by pressing "settings" in the project, and then choosing API.

## How was this built?

I "stole" everything from [Cliff Rowley](https://github.com/cliffrowley) who did the [Circle CI package](https://github.com/cliffrowley/atom-circle-ci) for Atom.

All credits goes to Cliff.

## Limitations

This is by no means perfect.
Please consider contributing if you believe you have ideas on how to make it better.

This Semaphore package has much the same limitations as Cliffs Circle CI package.

However, the following actually works with Semaphore

### Multiple projects

You are only able to input one authentication token.
This authentication token binds to your Semaphore account so you should be able to track multiple projects.
The package will look up the status of the build based on the Github repository (`username/project`) as well as the current branch name.

## Contributing

Issues, sugestions and pull requests are more than welcome.

## TODO

Write specs.
