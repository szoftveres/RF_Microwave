#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# SPDX-License-Identifier: GPL-3.0
#
# GNU Radio Python Flow Graph
# Title: FM Radio
# GNU Radio version: 3.10.5.1

from packaging.version import Version as StrictVersion

if __name__ == '__main__':
    import ctypes
    import sys
    if sys.platform.startswith('linux'):
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print("Warning: failed to XInitThreads()")

from PyQt5 import Qt
from gnuradio import qtgui
from gnuradio.filter import firdes
import sip
from gnuradio import analog
from gnuradio import audio
from gnuradio import blocks
from gnuradio import filter
from gnuradio import gr
from gnuradio.fft import window
import sys
import signal
from argparse import ArgumentParser
from gnuradio.eng_arg import eng_float, intx
from gnuradio import eng_notation
from gnuradio.qtgui import Range, RangeWidget
from PyQt5 import QtCore
import osmosdr
import time



from gnuradio import qtgui

class fm_stereo(gr.top_block, Qt.QWidget):

    def __init__(self):
        gr.top_block.__init__(self, "FM Radio", catch_exceptions=True)
        Qt.QWidget.__init__(self)
        self.setWindowTitle("FM Radio")
        qtgui.util.check_set_qss()
        try:
            self.setWindowIcon(Qt.QIcon.fromTheme('gnuradio-grc'))
        except:
            pass
        self.top_scroll_layout = Qt.QVBoxLayout()
        self.setLayout(self.top_scroll_layout)
        self.top_scroll = Qt.QScrollArea()
        self.top_scroll.setFrameStyle(Qt.QFrame.NoFrame)
        self.top_scroll_layout.addWidget(self.top_scroll)
        self.top_scroll.setWidgetResizable(True)
        self.top_widget = Qt.QWidget()
        self.top_scroll.setWidget(self.top_widget)
        self.top_layout = Qt.QVBoxLayout(self.top_widget)
        self.top_grid_layout = Qt.QGridLayout()
        self.top_layout.addLayout(self.top_grid_layout)

        self.settings = Qt.QSettings("GNU Radio", "fm_stereo")

        try:
            if StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
                self.restoreGeometry(self.settings.value("geometry").toByteArray())
            else:
                self.restoreGeometry(self.settings.value("geometry"))
        except:
            pass

        ##################################################
        # Variables
        ##################################################
        self.tuner_freq = tuner_freq = 95700000
        self.st_enh = st_enh = 0
        self.rfgain = rfgain = 20
        self.phasedelay = phasedelay = 9
        self.mono = mono = 0
        self.audio_samp_rate = audio_samp_rate = 44100

        ##################################################
        # Blocks
        ##################################################

        self._tuner_freq_range = Range(88000000, 108000000, 100000, 95700000, 200)
        self._tuner_freq_win = RangeWidget(self._tuner_freq_range, self.set_tuner_freq, "Tuning", "counter_slider", int, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._tuner_freq_win)
        self._st_enh_choices = {'Pressed': 0.25, 'Released': 0}

        _st_enh_toggle_switch = qtgui.GrToggleSwitch(self.set_st_enh, 'Enhanced Stereo', self._st_enh_choices, False, "green", "gray", 4, 50, 1, 1, self, 'value')
        self.st_enh = _st_enh_toggle_switch

        self.top_layout.addWidget(_st_enh_toggle_switch)
        if "int" == "int":
        	isFloat = False
        	scaleFactor = 1
        else:
        	isFloat = True
        	scaleFactor = 1

        _rfgain_dial_control = qtgui.GrDialControl('RF Gain', self, (-20),35,20,"default",self.set_rfgain,isFloat, scaleFactor, 100, False, "'value'")
        self.rfgain = _rfgain_dial_control

        self.top_layout.addWidget(_rfgain_dial_control)
        self._phasedelay_range = Range(0, 18, 1, 9, 200)
        self._phasedelay_win = RangeWidget(self._phasedelay_range, self.set_phasedelay, "Stereo Phasing", "counter_slider", int, QtCore.Qt.Horizontal)
        self.top_layout.addWidget(self._phasedelay_win)
        self._mono_choices = {'Pressed': 1, 'Released': 0}

        _mono_toggle_switch = qtgui.GrToggleSwitch(self.set_mono, 'Mono', self._mono_choices, False, "green", "gray", 4, 50, 1, 1, self, 'value')
        self.mono = _mono_toggle_switch

        self.top_layout.addWidget(_mono_toggle_switch)
        self.rtlsdr_source_0 = osmosdr.source(
            args="numchan=" + str(1) + " " + ""
        )
        self.rtlsdr_source_0.set_time_unknown_pps(osmosdr.time_spec_t())
        self.rtlsdr_source_0.set_sample_rate((audio_samp_rate*32))
        self.rtlsdr_source_0.set_center_freq(tuner_freq, 0)
        self.rtlsdr_source_0.set_freq_corr(0, 0)
        self.rtlsdr_source_0.set_dc_offset_mode(0, 0)
        self.rtlsdr_source_0.set_iq_balance_mode(0, 0)
        self.rtlsdr_source_0.set_gain_mode(False, 0)
        self.rtlsdr_source_0.set_gain(rfgain, 0)
        self.rtlsdr_source_0.set_if_gain(20, 0)
        self.rtlsdr_source_0.set_bb_gain(20, 0)
        self.rtlsdr_source_0.set_antenna('', 0)
        self.rtlsdr_source_0.set_bandwidth(0, 0)
        self.rational_resampler_xxx_0_0 = filter.rational_resampler_fff(
                interpolation=1,
                decimation=16,
                taps=[],
                fractional_bw=0)
        self.rational_resampler_xxx_0 = filter.rational_resampler_fff(
                interpolation=1,
                decimation=16,
                taps=[],
                fractional_bw=0)
        self.qtgui_freq_sink_x_0_0 = qtgui.freq_sink_c(
            512, #size
            window.WIN_BLACKMAN_hARRIS, #wintype
            0, #fc
            (audio_samp_rate*32), #bw
            "", #name
            1,
            None # parent
        )
        self.qtgui_freq_sink_x_0_0.set_update_time(0.10)
        self.qtgui_freq_sink_x_0_0.set_y_axis((-100), 10)
        self.qtgui_freq_sink_x_0_0.set_y_label('RF Spectrum', 'dB')
        self.qtgui_freq_sink_x_0_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, 0.0, 0, "")
        self.qtgui_freq_sink_x_0_0.enable_autoscale(False)
        self.qtgui_freq_sink_x_0_0.enable_grid(True)
        self.qtgui_freq_sink_x_0_0.set_fft_average(1.0)
        self.qtgui_freq_sink_x_0_0.enable_axis_labels(True)
        self.qtgui_freq_sink_x_0_0.enable_control_panel(False)
        self.qtgui_freq_sink_x_0_0.set_fft_window_normalized(False)



        labels = ['', '', '', '', '',
            '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
            "magenta", "yellow", "dark red", "dark green", "dark blue"]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]

        for i in range(1):
            if len(labels[i]) == 0:
                self.qtgui_freq_sink_x_0_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_freq_sink_x_0_0.set_line_label(i, labels[i])
            self.qtgui_freq_sink_x_0_0.set_line_width(i, widths[i])
            self.qtgui_freq_sink_x_0_0.set_line_color(i, colors[i])
            self.qtgui_freq_sink_x_0_0.set_line_alpha(i, alphas[i])

        self._qtgui_freq_sink_x_0_0_win = sip.wrapinstance(self.qtgui_freq_sink_x_0_0.qwidget(), Qt.QWidget)
        self.top_layout.addWidget(self._qtgui_freq_sink_x_0_0_win)
        self.qtgui_freq_sink_x_0 = qtgui.freq_sink_f(
            512, #size
            window.WIN_BLACKMAN_hARRIS, #wintype
            0, #fc
            (audio_samp_rate*16), #bw
            "", #name
            1,
            None # parent
        )
        self.qtgui_freq_sink_x_0.set_update_time(0.10)
        self.qtgui_freq_sink_x_0.set_y_axis((-100), 10)
        self.qtgui_freq_sink_x_0.set_y_label('Audio Baseband', 'dB')
        self.qtgui_freq_sink_x_0.set_trigger_mode(qtgui.TRIG_MODE_FREE, 0.0, 0, "")
        self.qtgui_freq_sink_x_0.enable_autoscale(False)
        self.qtgui_freq_sink_x_0.enable_grid(False)
        self.qtgui_freq_sink_x_0.set_fft_average(0.2)
        self.qtgui_freq_sink_x_0.enable_axis_labels(True)
        self.qtgui_freq_sink_x_0.enable_control_panel(False)
        self.qtgui_freq_sink_x_0.set_fft_window_normalized(False)


        self.qtgui_freq_sink_x_0.set_plot_pos_half(not False)

        labels = ['', '', '', '', '',
            '', '', '', '', '']
        widths = [1, 1, 1, 1, 1,
            1, 1, 1, 1, 1]
        colors = ["blue", "red", "green", "black", "cyan",
            "magenta", "yellow", "dark red", "dark green", "dark blue"]
        alphas = [1.0, 1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0, 1.0]

        for i in range(1):
            if len(labels[i]) == 0:
                self.qtgui_freq_sink_x_0.set_line_label(i, "Data {0}".format(i))
            else:
                self.qtgui_freq_sink_x_0.set_line_label(i, labels[i])
            self.qtgui_freq_sink_x_0.set_line_width(i, widths[i])
            self.qtgui_freq_sink_x_0.set_line_color(i, colors[i])
            self.qtgui_freq_sink_x_0.set_line_alpha(i, alphas[i])

        self._qtgui_freq_sink_x_0_win = sip.wrapinstance(self.qtgui_freq_sink_x_0.qwidget(), Qt.QWidget)
        self.top_layout.addWidget(self._qtgui_freq_sink_x_0_win)
        self.low_pass_filter_0 = filter.fir_filter_ccf(
            2,
            firdes.low_pass(
                1,
                (audio_samp_rate*32),
                100000,
                300000,
                window.WIN_HAMMING,
                6.76))
        self.blocks_threshold_ff_0_0_0 = blocks.threshold_ff((-0.1), 0.1, 0)
        self.blocks_threshold_ff_0_0 = blocks.threshold_ff((-0.1), 0.1, 0)
        self.blocks_threshold_ff_0 = blocks.threshold_ff((-0.1), 0.1, 0)
        self.blocks_sub_xx_1_0 = blocks.sub_ff(1)
        self.blocks_sub_xx_1 = blocks.sub_ff(1)
        self.blocks_null_sink_0 = blocks.null_sink(gr.sizeof_float*1)
        self.blocks_multiply_xx_1 = blocks.multiply_vcc(1)
        self.blocks_multiply_xx_0_1 = blocks.multiply_vff(1)
        self.blocks_multiply_xx_0 = blocks.multiply_vff(1)
        self.blocks_multiply_const_vxx_2 = blocks.multiply_const_ff((1 - (mono * 0.5)))
        self.blocks_multiply_const_vxx_1_0 = blocks.multiply_const_ff((1 + (st_enh * 2)))
        self.blocks_multiply_const_vxx_1 = blocks.multiply_const_ff((1 + (st_enh * 2)))
        self.blocks_multiply_const_vxx_0_0 = blocks.multiply_const_ff((-1))
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_ff(st_enh)
        self.blocks_delay_0_0 = blocks.delay(gr.sizeof_gr_complex*1, 1)
        self.blocks_delay_0 = blocks.delay(gr.sizeof_float*1, phasedelay)
        self.blocks_conjugate_cc_0 = blocks.conjugate_cc()
        self.blocks_complex_to_magphase_0 = blocks.complex_to_magphase(1)
        self.blocks_add_xx_0 = blocks.add_vff(1)
        self.blocks_add_const_vxx_0_0_0_0 = blocks.add_const_ff((mono * 1000))
        self.blocks_add_const_vxx_0_0_0 = blocks.add_const_ff((mono * 1000))
        self.blocks_abs_xx_0 = blocks.abs_ff(1)
        self.band_pass_filter_0_1 = filter.fir_filter_fff(
            1,
            firdes.band_pass(
                2,
                (audio_samp_rate*16),
                18000,
                20000,
                1000,
                window.WIN_RECTANGULAR,
                6.76))
        self.band_pass_filter_0_0 = filter.fir_filter_fff(
            1,
            firdes.band_pass(
                100,
                (audio_samp_rate*16),
                36000,
                40000,
                1000,
                window.WIN_RECTANGULAR,
                6.76))
        self.band_pass_filter_0 = filter.fir_filter_fff(
            1,
            firdes.band_pass(
                1000,
                (audio_samp_rate*16),
                18000,
                20000,
                1000,
                window.WIN_RECTANGULAR,
                6.76))
        self.audio_sink_0 = audio.sink(audio_samp_rate, 'default', True)
        self.analog_fm_deemph_0_0 = analog.fm_deemph(fs=(audio_samp_rate*16), tau=(75e-6))
        self.analog_fm_deemph_0 = analog.fm_deemph(fs=(audio_samp_rate*16), tau=(75e-6))


        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_fm_deemph_0, 0), (self.rational_resampler_xxx_0, 0))
        self.connect((self.analog_fm_deemph_0_0, 0), (self.rational_resampler_xxx_0_0, 0))
        self.connect((self.band_pass_filter_0, 0), (self.blocks_threshold_ff_0_0_0, 0))
        self.connect((self.band_pass_filter_0_0, 0), (self.blocks_add_const_vxx_0_0_0_0, 0))
        self.connect((self.band_pass_filter_0_0, 0), (self.blocks_multiply_const_vxx_0_0, 0))
        self.connect((self.band_pass_filter_0_1, 0), (self.blocks_abs_xx_0, 0))
        self.connect((self.blocks_abs_xx_0, 0), (self.blocks_delay_0, 0))
        self.connect((self.blocks_add_const_vxx_0_0_0, 0), (self.blocks_threshold_ff_0, 0))
        self.connect((self.blocks_add_const_vxx_0_0_0_0, 0), (self.blocks_threshold_ff_0_0, 0))
        self.connect((self.blocks_add_xx_0, 0), (self.blocks_multiply_const_vxx_0, 0))
        self.connect((self.blocks_complex_to_magphase_0, 1), (self.band_pass_filter_0, 0))
        self.connect((self.blocks_complex_to_magphase_0, 1), (self.blocks_multiply_const_vxx_2, 0))
        self.connect((self.blocks_complex_to_magphase_0, 0), (self.blocks_null_sink_0, 0))
        self.connect((self.blocks_complex_to_magphase_0, 1), (self.qtgui_freq_sink_x_0, 0))
        self.connect((self.blocks_conjugate_cc_0, 0), (self.blocks_multiply_xx_1, 1))
        self.connect((self.blocks_delay_0, 0), (self.band_pass_filter_0_0, 0))
        self.connect((self.blocks_delay_0_0, 0), (self.blocks_conjugate_cc_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_sub_xx_1, 1))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.blocks_sub_xx_1_0, 1))
        self.connect((self.blocks_multiply_const_vxx_0_0, 0), (self.blocks_add_const_vxx_0_0_0, 0))
        self.connect((self.blocks_multiply_const_vxx_1, 0), (self.audio_sink_0, 0))
        self.connect((self.blocks_multiply_const_vxx_1_0, 0), (self.audio_sink_0, 1))
        self.connect((self.blocks_multiply_const_vxx_2, 0), (self.blocks_multiply_xx_0, 0))
        self.connect((self.blocks_multiply_const_vxx_2, 0), (self.blocks_multiply_xx_0_1, 0))
        self.connect((self.blocks_multiply_xx_0, 0), (self.analog_fm_deemph_0, 0))
        self.connect((self.blocks_multiply_xx_0_1, 0), (self.analog_fm_deemph_0_0, 0))
        self.connect((self.blocks_multiply_xx_1, 0), (self.blocks_complex_to_magphase_0, 0))
        self.connect((self.blocks_sub_xx_1, 0), (self.blocks_multiply_const_vxx_1_0, 0))
        self.connect((self.blocks_sub_xx_1_0, 0), (self.blocks_multiply_const_vxx_1, 0))
        self.connect((self.blocks_threshold_ff_0, 0), (self.blocks_multiply_xx_0_1, 1))
        self.connect((self.blocks_threshold_ff_0_0, 0), (self.blocks_multiply_xx_0, 1))
        self.connect((self.blocks_threshold_ff_0_0_0, 0), (self.band_pass_filter_0_1, 0))
        self.connect((self.low_pass_filter_0, 0), (self.blocks_delay_0_0, 0))
        self.connect((self.low_pass_filter_0, 0), (self.blocks_multiply_xx_1, 0))
        self.connect((self.rational_resampler_xxx_0, 0), (self.blocks_add_xx_0, 1))
        self.connect((self.rational_resampler_xxx_0, 0), (self.blocks_sub_xx_1_0, 0))
        self.connect((self.rational_resampler_xxx_0_0, 0), (self.blocks_add_xx_0, 0))
        self.connect((self.rational_resampler_xxx_0_0, 0), (self.blocks_sub_xx_1, 0))
        self.connect((self.rtlsdr_source_0, 0), (self.low_pass_filter_0, 0))
        self.connect((self.rtlsdr_source_0, 0), (self.qtgui_freq_sink_x_0_0, 0))


    def closeEvent(self, event):
        self.settings = Qt.QSettings("GNU Radio", "fm_stereo")
        self.settings.setValue("geometry", self.saveGeometry())
        self.stop()
        self.wait()

        event.accept()

    def get_tuner_freq(self):
        return self.tuner_freq

    def set_tuner_freq(self, tuner_freq):
        self.tuner_freq = tuner_freq
        self.rtlsdr_source_0.set_center_freq(self.tuner_freq, 0)

    def get_st_enh(self):
        return self.st_enh

    def set_st_enh(self, st_enh):
        self.st_enh = st_enh
        self.blocks_multiply_const_vxx_0.set_k(self.st_enh)
        self.blocks_multiply_const_vxx_1.set_k((1 + (self.st_enh * 2)))
        self.blocks_multiply_const_vxx_1_0.set_k((1 + (self.st_enh * 2)))

    def get_rfgain(self):
        return self.rfgain

    def set_rfgain(self, rfgain):
        self.rfgain = rfgain
        self.rtlsdr_source_0.set_gain(self.rfgain, 0)

    def get_phasedelay(self):
        return self.phasedelay

    def set_phasedelay(self, phasedelay):
        self.phasedelay = phasedelay
        self.blocks_delay_0.set_dly(int(self.phasedelay))

    def get_mono(self):
        return self.mono

    def set_mono(self, mono):
        self.mono = mono
        self.blocks_add_const_vxx_0_0_0.set_k((self.mono * 1000))
        self.blocks_add_const_vxx_0_0_0_0.set_k((self.mono * 1000))
        self.blocks_multiply_const_vxx_2.set_k((1 - (self.mono * 0.5)))

    def get_audio_samp_rate(self):
        return self.audio_samp_rate

    def set_audio_samp_rate(self, audio_samp_rate):
        self.audio_samp_rate = audio_samp_rate
        self.band_pass_filter_0.set_taps(firdes.band_pass(1000, (self.audio_samp_rate*16), 18000, 20000, 1000, window.WIN_RECTANGULAR, 6.76))
        self.band_pass_filter_0_0.set_taps(firdes.band_pass(100, (self.audio_samp_rate*16), 36000, 40000, 1000, window.WIN_RECTANGULAR, 6.76))
        self.band_pass_filter_0_1.set_taps(firdes.band_pass(2, (self.audio_samp_rate*16), 18000, 20000, 1000, window.WIN_RECTANGULAR, 6.76))
        self.low_pass_filter_0.set_taps(firdes.low_pass(1, (self.audio_samp_rate*32), 100000, 300000, window.WIN_HAMMING, 6.76))
        self.qtgui_freq_sink_x_0.set_frequency_range(0, (self.audio_samp_rate*16))
        self.qtgui_freq_sink_x_0_0.set_frequency_range(0, (self.audio_samp_rate*32))
        self.rtlsdr_source_0.set_sample_rate((self.audio_samp_rate*32))




def main(top_block_cls=fm_stereo, options=None):

    if StrictVersion("4.5.0") <= StrictVersion(Qt.qVersion()) < StrictVersion("5.0.0"):
        style = gr.prefs().get_string('qtgui', 'style', 'raster')
        Qt.QApplication.setGraphicsSystem(style)
    qapp = Qt.QApplication(sys.argv)

    tb = top_block_cls()

    tb.start()

    tb.show()

    def sig_handler(sig=None, frame=None):
        tb.stop()
        tb.wait()

        Qt.QApplication.quit()

    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    timer = Qt.QTimer()
    timer.start(500)
    timer.timeout.connect(lambda: None)

    qapp.exec_()

if __name__ == '__main__':
    main()
