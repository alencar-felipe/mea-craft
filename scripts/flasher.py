#!/usr/bin/env python3
"""
Send a binary file over PySerial for flashing.
"""

import argparse
import serial
import struct

def flash(file_path, serial_port, baud_rate=9600):
    # Read the file data
    with open(file_path, 'rb') as file:
        data = file.read()

    # Calculate the size of the data
    size = len(data)

    # Calculate the checksum
    checksum = 0
    for i in data:
        checksum = (checksum + i) % 256

    # Pack the size and checksum into bytes
    size_bytes = struct.pack('<I', size)
    checksum_byte = struct.pack('<B', checksum)

    # Open the serial port
    with serial.Serial(serial_port, baud_rate) as ser:
        # Send the size, data, and checksum over serial
        ser.write(size_bytes)
        ser.write(data)
        ser.write(checksum_byte)
        ser.flush()

def main():
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('file', help='Binary file path')
    parser.add_argument('port', help='Serial port name')
    parser.add_argument('-b', '--baud-rate', type=int, default=115200,
        help='Serial baud rate')

    args = parser.parse_args()
    file_path = args.file
    serial_port = args.port
    baud_rate = args.baud_rate

    flash(file_path, serial_port, baud_rate)

if __name__ == '__main__':
    main()