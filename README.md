# Gitbook Starter Kit

##What?
This is a starter repo for your gitbook.
You may fork it and get your book started, or clone it and remove the .git folder in the repo to have a fresh start.
This file serves as the README file for the repository, as well as the introduction to your gitbook!

##Why Write This?
Gitbook has a great way of [documenting](http://help.gitbook.io) the specifics of how to work with it, but I wanted to create an opinionated guide for workflow that people can use use without headeaches, and work together as a team.  This is my workflow and I'm outlining what works for me, and this will not necessarily fit everyone that is using a tool as flexible as gitbook.


## More Information
I'm not going to re-write gitbook documentation.  If I wanted to add / edit it, I would do it either on their [help site](http://help.gitbook.io) or on their super useful [README](https://github.com/GitbookIO/gitbook/blob/master/README.md).  Everything regarding how to work with this repo is contained above.

##How? (AKA the good stuff)
*  Let's start with some assumptions:
  * You keep all your code / things you work on in ~/Code (which is the same as /Users/Your-User-Name/Code)
  * You want to call your book "BookName"

### Setup your computer
*  Install node by going to the [Node Site](http://nodejs.org/), clicking install and downloading the package.
*  Once the install finishes, open your terminal (Applications -> Utilities -> Terminal)
*  In your command line, run `npm install -g gitbook`

### Get your starter kit on
* Navigate your browser to the [gitbook starter kit repo](https://github.com/MrMaksimize/gitbook-starter-kit);
* Make sure you have a github account.
* Click the Fork Button: ([screenshot](http://mrm-screen.s3.amazonaws.com/MrMaksimizegitbookstarterkit_20140707_085000_20140707_085006.png))
* Rename the repo to what you want your book to be called:
  * Click settings from the home screen of the forked repo (forking creates a copy of the repository under your username). ([screenshot](http://mrm-screen.s3.amazonaws.com/MrMaksimizegitbookstarterkit_20140707_100321_20140707_100325.png))
  * Rename the repo ([screenshot](http://mrm-screen.s3.amazonaws.com/Options_20140707_100417_20140707_100421.png))
* Clone the repo to your machine.  Remember our assumptions.  I will walk through how I would do it:
  * Find the URL of the new forked repo. ([screenshot](http://mrm-screen.s3.amazonaws.com/MrMaksimizegitbookstarterkit_20140707_085400_20140707_085418.png))
  * Open terminal back up and execute the following:
  * `git clone YOUR_REPO_URL ~/Code/BookName`
  * `cd ~/Code/BookName`
  * `gitbook serve`
  * The last command will start a local server at port 4000 which you can access at http://localhost:4000;  It will automatically refresh on changes.  Now you're ready to start writing!

### Putting the pen to paper.

#### Organizing
This is not the only way to do it, but I think it makes sense to organze the file structure as the example set up in the starter repo.  The order of the files does not seem to matter (at least from what I can tell) because it's all controlled by the SUMMARY.md file (more on that later), but I recommend it for your own sanity.

#### How everything works together
![all together](http://mrm-screen.s3.amazonaws.com/UsersMrMaksimizeCode_gitbooksgitbookstarterkit_20140707_091414_20140707_091554.png)
All of the organization comes from the SUMMARY.md file.  The file structure does not matter as much as long the links in the SUMMARY.md file are correct.  The README.md file at the top of the repo (what you're reading now) acts the introduction to the book.  That's the only thing that's set as default.  Everything else can be controlled through the README file.

#### Actually writing
Gitbook has a great  editor that will help you write Markdown and see the preview side by side.  However, it does seem a little buggy still and people have trouble using it, therefore I wouldn't recommend it.  If you are comfortable creating your own blank files (File -> New in Finder), I would recommend using [MacDown](http://macdown.uranusjr.com/), an open source markdown editor.

### Publishing
This is another fairly confusing part. If you want to publish your book on gitbook.io (and I'm assuming you do), you want your workflow to look like this:

*  Write some stuff locally.  Preview it at localhost:4000
*  Become happy with what you wrote.  Commit it to git and push it to github.
*  Once github receives the code, it tells gitbook.io to re-build your book in different formats
*  In about 10 minutes, you see your new published version of the book!

So let's make it happen!

*  [Login to Gitbook.io](https://www.gitbook.io/login) with github. ([screenshot](http://mrm-screen.s3.amazonaws.com/Sign_in__GitBook_20140707_092520_20140707_092525.png))
*  [Create a new book](https://www.gitbook.io/new)
*  At the book home page, go to settings ([screenshot](http://mrm-screen.s3.amazonaws.com/TestBook__GitBook_20140707_092736_20140707_092739.png))
*  Add the github url to the book under Github Repo.  In our case it will be YOUR_USER_NAME/gitbook-starter-kit ([screenshot](http://mrm-screen.s3.amazonaws.com/Settings__TestBook__GitBook_20140707_095646_20140707_095652.png)).
*  Click the "Add Deployment Webhook" button.

Now, whenever you push to Github, it will send a payload with the information of the push to gitbook and gitbook will know to start the build!



