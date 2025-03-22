#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: Not titled yet
# GNU Radio version: 3.10.5.1

from gnuradio import blocks
from gnuradio import gr
from gnuradio.filter import firdes
from gnuradio.fft import window
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio import uhd
import time
from gnuradio import zeromq
import zeromq_demo_rev2_epy_module_0 as epy_module_0  # embedded python module


def snipfcn_snippet_0(self):
    import threading
    print("Starting server")
    self.channel=100
    threading.Thread(target=epy_module_0.jmf_server,args=(self,)).start()


def snippets_main_after_init(tb):
    snipfcn_snippet_0(tb)


class zeromq_demo_rev2(gr.top_block):

    def __init__(self):
        gr.top_block.__init__(self, "Not titled yet", catch_exceptions=True)

        ##################################################
        # Variables
        ##################################################
        self.samp_rate = samp_rate = int(5E6)
        self.f = f = 5.5e9
        self.N = N = 1000

        ##################################################
        # Blocks
        ##################################################

        self.zeromq_pub_sink_0 = zeromq.pub_sink(gr.sizeof_gr_complex, (N), 'tcp://192.168.77.168:5555', 100, False, (-1), '', True)
        self.uhd_usrp_source_0 = uhd.usrp_source(
            ",".join(("", '')),
            uhd.stream_args(
                cpu_format="fc32",
                otw_format="sc16",
                args='',
                channels=list(range(0,2)),
            ),
        )
        self.uhd_usrp_source_0.set_samp_rate(samp_rate)
        self.uhd_usrp_source_0.set_time_unknown_pps(uhd.time_spec(0))

        self.uhd_usrp_source_0.set_center_freq(f, 0)
        self.uhd_usrp_source_0.set_antenna("TX/RX", 0)
        self.uhd_usrp_source_0.set_rx_agc(False, 0)
        self.uhd_usrp_source_0.set_gain(67, 0)  # surveillance A

        self.uhd_usrp_source_0.set_center_freq(f, 1)
        self.uhd_usrp_source_0.set_antenna("TX/RX", 1)
        self.uhd_usrp_source_0.set_rx_agc(False, 1)
        self.uhd_usrp_source_0.set_gain(37, 1)  # ref in B
        self.blocks_stream_to_vector_0 = blocks.stream_to_vector(gr.sizeof_gr_complex*1, (N))
        self.blocks_interleave_0 = blocks.interleave(gr.sizeof_gr_complex*1, 1)


        ##################################################
        # Connections
        ##################################################
        self.connect((self.blocks_interleave_0, 0), (self.blocks_stream_to_vector_0, 0))
        self.connect((self.blocks_stream_to_vector_0, 0), (self.zeromq_pub_sink_0, 0))
        self.connect((self.uhd_usrp_source_0, 1), (self.blocks_interleave_0, 1))
        self.connect((self.uhd_usrp_source_0, 0), (self.blocks_interleave_0, 0))


    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.set_N(self.samp_rate)
        self.uhd_usrp_source_0.set_samp_rate(self.samp_rate)

    def get_f(self):
        return self.f

    def set_f(self, f):
        self.f = f
        self.uhd_usrp_source_0.set_center_freq(self.f, 0)
        self.uhd_usrp_source_0.set_center_freq(self.f, 1)

    def get_N(self):
        return self.N

    def set_N(self, N):
        self.N = N




def main(top_block_cls=zeromq_demo_rev2, options=None):
    tb = top_block_cls()
    snippets_main_after_init(tb)
    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        sys.exit(0)

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    tb.start()

    tb.wait()


if __name__ == '__main__':
    main()
