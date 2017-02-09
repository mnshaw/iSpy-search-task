# ispy-search-task
A visual search task using iSpy pictures for use in the Infant Cognition Lab at Carnegie Mellon University.

<h3>Instructions</h3>
<ol>
<li>Open visualSearch.m (in Matlab).</li>
<li>On the left sidebar, make sure you're in the folder visualSearch.m is in. If you're not, navigate to it. If it asks you to add it to your path, say yes.</li>
<li>In the Command Window below the code, type <b>visualSearch('<i>subjectId</i>')</b> (with the single quotes) and press enter. It will run by default for a maximum session of 3 minutes. If you want to change the maximum time for the task, type <b>visualSearch('<i>subjectId</i>', <i>timeInSeconds</i>)</b></li>
<li>Once you press enter, the program will switch to the PsychToolbox window and prompt the user to press the space bar.</li>
<li>After pressing the space bar, the iSpy image will be displayed. Press the leftmost pin to show the subject what a pin is and start the task. The timer will start as soon as that particular pin is clicked.</li>
<li>After the subject clicks on all the pins or the time is up, the task will finish, and results will be placed in a text file that can be found in the "results" folder.</li>
</ol>
