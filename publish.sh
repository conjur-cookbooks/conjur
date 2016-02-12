#!/bin/bash

summon -f secrets.ci.yml -- knife cookbook site share conjur "Other" -o ../. -VV
