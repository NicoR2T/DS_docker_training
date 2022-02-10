#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import, division, print_function

if __name__ == '__main__':
    try:
        from deepspeech_training import train as ds_train
    except ImportError:
        print('Training package is not installed. See training documentation.')
        raise

    try:
        from AIPM.deep_learning_power_measure.power_measure import experiment, parsers
    except ImportError:
        print('Error throughout the import of AIPowerMeter')
        raise

    driver = parsers.JsonParser("/mnt/consommation/")
    exp = experiment.Experiment(driver)

    p, q = exp.measure_yourself(period=2)
    ds_train.run_script()
    q.put(experiment.STOP_MESSAGE)