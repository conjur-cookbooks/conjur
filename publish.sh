#!/bin/bash

conjur env run -- knife cookbook site share conjur "Other" -o ../. -VV
