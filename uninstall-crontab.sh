#!/bin/bash
crontab -l > mycron
sed -i '/-t log2ram-scheduler/d' ./mycron
crontab mycron
rm mycron
