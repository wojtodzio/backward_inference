# Backward Chaining in First-Order Logic
This program uses backward chaining algorithm to implement `ASK` question for the `KnowledgeBase`.
Implementation is based on the description of the algorithm from the "Metody Sztucznej Inteligencji" (Methods of Artifical Intelligence) by Włodzimierz Kasprzak, and on a third edition of the “Artificial Intelligence A Modern Approach” by Stuart Russell and Peter Norvig.
The algorithm was modified to allow for terms to be in the form of the atomic forms and to prevent creating infinite loops.

## Examples and results of running on examplary data
You can see how it works and what kind of data it returns for specific inputs by looking at the tests.

## Running
There're two ways to run the program:
1. In the environment where Ruby binary is present, you can simply start the [bin/runner](bin/runner)
2. The project can be build to be run in the Windows environment where Ruby is not installed using [Traveling Ruby](https://github.com/phusion/traveling-ruby). To do so, you have to run, e.g. `rake package:win32` in the environment with Ruby. It will create 'backward_chaining-1.0.0-win32.zip', which can then be copied to a Windows machine. Just note, that performance on Windows is significantly worse.
