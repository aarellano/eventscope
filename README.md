MultiFinder
====

## Description

MultiFinder is a tool to explore point event temporal patterns. It is based on the idea behind [Eventflow][1], but we propose a solution where we **split the datasets** into two groups based on some binary attribute and attempt to identify association rules that are either the same or different for each class. It is expected that relations that occur in both sets, after the separation, are uninteresting. Relations that occur in only one group are expected to be more interesting because they can be used to distinguish between groups.

There is an incremental [live demo][18] of the app.

## Software components

This is a web application created with [AngularJS][2], and the visualizations are based on [D3.js][3]. The layout and styles use [Bootstrap][14].

We are using the [Yeoman][5] workflow to build and maintain this webapp. That means: 

* The application structure and configuration is created using [Yo][6], using the [generator-angular][7]
* All the web dependencies are managed using [Bower][4]
* [Grunt][8] is used to preprocess the files, run the application locally and build the deployment package

The scripts are written using [CoffeeScript][9]

## Development

#### 1. Get your node

Make sure you have [node.js][10] installed on your system. If you are using OS X [Homebrew][11] is the way to go, just `brew install node`. If you are using Linux you can follow [this guide][12]. If you are using Windows (really?), that guide will also help you.

#### 2. Clone the project

```
git clone git@github.com:aarellano/multifinder.git
```

#### 3. Install the dependencies

```
npm install
bower install
```

#### 4. You are ready to go!

```
grunt server
```

Grunt will precompile what is needed, and start a local server on port :9000 It usually also open your default browser for you pointing to localhost:9000

Grunt automatically makes use of Livereload, so any change that you make to a script or markup file will be instantly visible in your browser.

## Where to start

* We need to manage the basic concepts behind AngularJS. It's super well documented, and you can follow their [quick tutorial][13] to understand the basics.
* The Bootstrap [Grid System][15]. Also, getting familiar with its [Components][16] is very useful.
* It goes without saying, D3.js. [Scott Murray's D3 tutorial][17] is the _de facto_ starting point. It helps to understand the very basic concepts of D3. We'll need to go further as long as we need more complex visualizations.
* Git and GitHub to share and organize the code.



[1]: http://www.cs.umd.edu/hcil/eventflow/
[2]: http://angularjs.org/
[3]: http://d3js.org/
[4]: http://bower.io/
[5]: http://yeoman.io/
[6]: https://github.com/yeoman/yo
[7]: https://github.com/yeoman/generator-angular
[8]: http://gruntjs.com/
[9]: http://coffeescript.org/
[10]: http://nodejs.org/
[11]: http://brew.sh/
[12]: https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
[13]: http://docs.angularjs.org/tutorial
[14]: http://getbootstrap.com/
[15]: http://getbootstrap.com/css/#grid
[16]: http://getbootstrap.com/components/
[17]: http://alignedleft.com/tutorials/d3/
[18]: http://multifinder.herokuapp.com
