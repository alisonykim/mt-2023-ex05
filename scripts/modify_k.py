#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# modify_k.py

"""
Modify model config with the specified beam size.

Sample program call from main directory:
	python3 scripts/modify_k.py --model transformer_b --beam-size 4
"""

import os
import sys
import yaml
from argparse import ArgumentParser


def get_argument_parser() -> ArgumentParser:
	parser = ArgumentParser(description='Specify parameters for training.')
	parser.add_argument(
		'--model',
		type=str, required=True,
		help='Name of model with which to perform inference.'
	)
	parser.add_argument(
		'--beam-size',
		type=int, required=True,
		help='Size of beam.'
	)
	return parser


if __name__ == '__main__':
	# Parse CL args
	parser = get_argument_parser()
	args = parser.parse_args()

	# Define directories
	EX_DIR = os.getcwd() # Should be exercise directory 'mt-2023-ex05'
	MODELS_DIR = os.path.join(EX_DIR, 'configs')
	MODEL_PATH = os.path.join(MODELS_DIR, args.model + '.yaml')

	# Change YAML
	try:
		with open(MODEL_PATH) as config:
			yaml_doc = yaml.safe_load(config)
			yaml_doc['testing']['beam_size'] = args.beam_size
		
		MODEL_PATH_K = os.path.join(MODELS_DIR, args.model + '_' + str(args.beam_size) + '.yaml')
		with open(MODEL_PATH_K, 'w') as config_k:
			yaml.dump(yaml_doc, config_k, default_flow_style=False, sort_keys=False)
	except FileNotFoundError:
		print(f'Invalid model name {args.model}. Please try again with a valid model name, or train a model with this name and rerun this script.')
		sys.exit()