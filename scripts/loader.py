#!/usr/bin/env python

import argparse
import struct

import serial

def main():
    parser = argparse.ArgumentParser(description='Program loader')
    parser.add_argument('-f', '--file', default='/dev/null', help='set the input file')
    parser.add_argument('-p', '--port', required=True, help='set the output port')

    args = parser.parse_args()

    dev = serial.Serial(args.port)

    with open(args.file, 'r') as fd:
        data = fd.read()
        size = len(data) / 4
        dev.write(struct.pack('>H', size))
        words = [data[i:i+4] for i in range(0, len(data), 4)]
        for word in words:
            dev.write(word[::-1])

    dev.close()

if __name__ == "__main__":
    main()
