# Design Summary

## What should good measurement code do?

Anyone who has written code in MATLAB or something comparable (IGOR Pro, in the
author's case) has undoubtedly seen spaghetti code. Often there are many copies
of a measurement routine that differ only slightly, perhaps in the functionality
of what happens inside some for loop, etc.

We would like to have clear, reusable code to avoid redundancy and accidental
errors, both of which consume precious time on the part of the experimenters.
Consider an archetypal measurement scheme wherein we measure a device's response to
various stimuli (perhaps we measure current as a function of applied bias).
We should be able to write just one sweep function to do this.

The idea of *multiple dispatch*, natively supported in Julia, permits writing such
convenient and abstract code. For example, one sweep function could encompass various
sweep methods, where there is a unique method for any particular combination of
stimuli to measure a response. Multiple dispatch would be able to discern which method
to use based on the *types* of stimuli and response passed to the function.
This is just one example where the advantages of multiple dispatch are obvious.
We hope it will more broadly simplify the extension of measurement code while
ensuring continued reliability.

## Summary of Functionality

This package approaches the problem of measurement in an object oriented manner.
As such, Julia types are defined for instrument, instrument properties, independent
variables to be swept over during measurement, and dependent variables to be measured.
Interfacing with instruments, such as configuring their properties, sweeping through
parameters such as voltage, frequency, etc, and actually recording measurement values
coming from instruments, are all done through manipulation of instances of these types.

A careful framework of abstract super types has been fleshed out in this package,
along with sweeping and job scheduling/queueing functionality that expects subtypes
of the aforementioned super types. However, each user will have their
own unique instruments and measurements to perform. As such, users are expected
to write their own type definitions and some methods for those types; but when
properly written, they fit in seamlessly into the functionality written around
the super types described in the rest of this documentation.

Notably, this package implements queueing structure for measurement "jobs" , which
affords automation of measurements and facilitates use of the same instruments
by multiple users warrants. The queue schedules jobs automatically and in the
background of the Julia interface that the user is using. We call these jobs
"sweep jobs", in accordance with what one usually thinking of measurement:
measuring some dependent variable with respect to some independent variable that
is swept across a range of values. When the user executes the `sweep` function,
job objects are automatically generated, passed to the queue, and schedules jobs
according to their priority without any additional input from the user.

Finally, InstrumentControl.jl communicates with a relational database server, set
up by [ICDataServer.jl](https://github.com/PainterQubits/ICDataServer.jl), which
is used to maintain a log of information for each job. An entry in the database is
automatically made for each job submitted to the queue  
