#!/usr/bin/python3
from flabs_utils import bit_list_utils as blu

ACS_OFFSET = 1


def manchester_decode(raw_packet):
    decoded_packet = []
    for i in range(1, len(raw_packet), 2):
        decoded_packet.append(raw_packet[i])
    return decoded_packet


class LrsPayload:
    def __init__(self, raw_packet):
        self.raw = raw_packet
        # manchester decode
        self.packet = manchester_decode(self.raw)
        # break out packet contents
        self.header = self.packet[0:16]
        self.rest_id = self.packet[16:24]
        self.sys_id = self.packet[24:28]
        self.pager_num = self.packet[28:40]
        self.reserved_0 = self.packet[40:60]
        self.reserved_1 = self.packet[60:80]
        self.action = self.packet[80:88]
        self.acs_bits = self.packet[88:96]
        self.acs_uint = blu.bit_list_to_uint(self.acs_bits)

        self.valid = True
        if blu.bit_list_to_byte_list(self.header) != [0xfc, 0x2d]:
            self.valid = False
        if blu.bit_list_to_byte_list(self.rest_id) != [0x02]:
            self.valid = False
        if self.sys_id != [0, 0, 0, 0]:
            self.valid = False
        if self.reserved_0 != 20 * [0, ]:
            self.valid = False
        if self.reserved_1 != 20 * [0, ]:
            self.valid = False
        byte_list = blu.bit_list_to_byte_list(self.packet[0:88])
        acs_nomod = sum(byte_list)
        acs_comp = acs_nomod % 256 + ACS_OFFSET
        if self.acs_uint != acs_comp:
            self.valid = False

    def print_contents(self, verbose=False):
        if verbose:
            print("LRS Packet:")
            print("    header:  {}".format(blu.bit_list_to_hex_str(self.header)))
            print("    rest id: {}".format(blu.bit_list_to_hex_str(self.rest_id)))
            print("    sys id : {}".format(blu.bit_list_to_hex_str([0, 0, 0, 0] + self.sys_id)[1:]))
            print("    pager:   {}".format(blu.bit_list_to_hex_str([0, 0, 0, 0] + self.pager_num)[1:]))
            print("    resv 0:  {}".format(blu.bit_list_to_hex_str([0, 0, 0, 0] + self.reserved_0)[1:]))
            print("    resv 1:  {}".format(blu.bit_list_to_hex_str([0, 0, 0, 0] + self.reserved_1)[1:]))
            print("    action:  {}".format(blu.bit_list_to_hex_str(self.action)))
            print("    crc 8:   {}".format(blu.bit_list_to_hex_str(self.acs_bits)))
        else:
            if self.valid:
                print("Pager: {}".format(blu.bit_list_to_hex_str([0, 0, 0, 0] + self.pager_num)[1:]))
            else:
                print("BAD PACKET")


# read the data from a file
with open("bits_1_10.txt", 'r') as grc_out_file:
    lines = grc_out_file.readlines()
    # build a list
    raw_packet_list = []
    for line in lines:
        packet = []
        for i in range(3, len(line) - 2, 2):
            packet.append(int(line[i]))
        raw_packet_list.append(packet)

packet_list = []
for r in raw_packet_list:
    packet_list.append(LrsPayload(r))

for p in packet_list:
    p.print_contents(verbose=True)

# display cleanly

