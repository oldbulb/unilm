#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
from xml.dom.minidom import parse
import xml.dom.minidom


def parse_config():
    parser = argparse.ArgumentParser()
    parser.add_argument('--pred_txt', type=str, default='zh.txt')
    parser.add_argument('--src_xml', type=str, default='data/source/test/test.ms-zh.ms.xml')
    parser.add_argument('--pred_xml', type=str, default='data/source/test/test.ms-zh.zh.xml')

    return parser.parse_args()


if __name__ == "__main__":

    args = parse_config()
    pre_out = []

    with open(args.pred_txt, 'r', encoding='utf-8') as f:
        for snt in f.readlines():
            pre_out.append(snt.rstrip())

    DOMTree = xml.dom.minidom.parse(args.src_xml)
    collection = DOMTree.documentElement

    segs = collection.getElementsByTagName("seg")

    for i, seg in enumerate(segs):
        seg.childNodes[0].data = pre_out[i]

    with open(args.pred_xml, 'w') as f:
        DOMTree.writexml(f, encoding='utf-8')
