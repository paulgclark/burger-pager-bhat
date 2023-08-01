#!/usr/bin/python3
import argparse
import pmt
import fsk_tx
import zmq


ZMQ_ADDR = "tcp://127.0.0.1:5555"


class ZmqSocketToTx:
    def __init__(self, tcp_str=ZMQ_ADDR):
        self.context = zmq.Context.instance()
        self.socket = self.context.socket(zmq.PUSH)
        self.socket.bind(tcp_str)

    def send_raw_bytes(self, byte_list):
        # get payload size
        payload_size = len(byte_list)
        # build an empty vector
        data = pmt.make_u8vector(payload_size, 0x00)
        # fill the vector with unsigned byte data to send
        for i in range(payload_size):
            pmt.u8vector_set(data, i, byte_list[i])
        # build the message, which is a pair consisting of
        # the message metadata (not needed here) and the
        # information we want to send (the vector)
        msg = pmt.cons(pmt.PMT_NIL, data)
        # the message must be serialized as a string so that
        # it's in the form the GNU Radio source expects
        msg = pmt.serialize_str(msg)
        self.socket.send(msg)


# performs inverted manchester encoding on byte data
def manchester_encode(payload):
    encoded = []
    for b in payload:
        # pre-assign byte to all manchester 0s
        e = 0x55
        # check each data bit and flip the manchester pair if 1
        if b & 0x80:
            e ^= 0xC0
        if b & 0x40:
            e ^= 0x30
        if b & 0x20:
            e ^= 0x0C
        if b & 0x10:
            e ^= 0x03
        encoded.append(e)
        e = 0x55
        if b & 0x08:
            e ^= 0xC0
        if b & 0x04:
            e ^= 0x30
        if b & 0x02:
            e ^= 0x0C
        if b & 0x01:
            e ^= 0x03
        encoded.append(e)
    return encoded


# payload
payload_template = [
    0xAA, 0xAA, 0xAA,  # preamble
    0xFC, 0x2D,        # sync word
    0x02,              # site id
    0x08,              # system id
    0x00,              # pager id
    0x00, 0x00, 0x00, 0x00, 0x00, # reserved fields
    0x01,              # action
    0x00               # checksum
    ]


def build_burst(payload, pager_id, action, debug=False):
    # apply pager id and action values
    payload[7] = pager_id
    payload[13] = action

    # compute and set checksum
    acs = 1 + sum(payload[3:-1]) % 256
    if debug:
        print("computed ACS: {:02X}".format(acs))
    # acs = 0x40
    payload[-1] = acs
    if debug:
        print("cs={:02X}".format(payload[-1]))

    # manchester encode
    encoded_bytes = manchester_encode(payload)

    # build the burst
    burst_bytes = [0x00, ] + 3 * encoded_bytes + [0x00, ]

    if debug:
        for b in burst_bytes:
            print("{:02X}".format(b), end=' ')
        print()

    return burst_bytes
    # fill it with the intended bytes
    # for i in range(vec_len):
    #     pmt.u8vector_set(vec, i, burst[i])

    # tx_pdu = pmt.cons(pmt.PMT_NIL, vec)


def main(pager_id_init, action_init):
    tx_socket = ZmqSocketToTx(tcp_str=ZMQ_ADDR)
    tx_fg = fsk_tx.fsk_tx()

    # start the flowgraph
    tx_fg.start()

    # loop and get command
    pager_id = pager_id_init
    action = action_init
    while True:
        user_text = input("Enter pager ID (1-255, or Q to quit):")
        if user_text.upper() == "Q":
            break
        try:
            if 255 >= int(user_text) > 0:
                pager_id = int(user_text)
        except:
            print("ERROR: Please enter an integer value between 1 and 255, inclusive")

        user_text = input("Enter action byte value (0-255, or Q to quit):")
        if user_text.upper() == "Q":
            break
        try:
            if 255 >= int(user_text) >= 0:
                action = int(user_text)
        except:
            print("ERROR: Please enter an integer value between 0 and 255, inclusive")

        # build encoded burst
        burst_bytes = build_burst(payload=payload_template, pager_id=pager_id, action=action)
        tx_socket.send_raw_bytes(burst_bytes)

    tx_fg.stop()


if __name__ == "__main__":
    # get the args
    parser = argparse.ArgumentParser("Transmit LRS Pager Signal")
    parser.add_argument("-p", "--pager_id", type=int, default=1,
                        help="pager ID (0-255)")
    parser.add_argument("-a", "--action", type=int, default=1,
                        help="action byte")
    parser.add_argument("-v", "--verbose", help="increase output verbosity",
                        action="store_true")
    args = parser.parse_args()

    main(args.pager_id, args.action)
