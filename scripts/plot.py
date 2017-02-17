import sys, copy
import matplotlib
import matplotlib.pyplot as plt
from math import sqrt, log
from collections import defaultdict
from scipy.interpolate import spline
import numpy as np

SPINE_COLOR = 'gray'

tableau20 = [(31, 119, 180), (174, 199, 232), (255, 127, 14), (255, 187, 120),
             (44, 160, 44), (152, 223, 138), (214, 39, 40), (255, 152, 150),
             (148, 103, 189), (197, 176, 213), (140, 86, 75), (196, 156, 148),
             (227, 119, 194), (247, 182, 210), (127, 127, 127), (199, 199, 199),
             (188, 189, 34), (219, 219, 141), (23, 190, 207), (158, 218, 229)]

# Scale Tableau20 colors to [0, 1] range
for i in range(len(tableau20)):
    r, g, b = tableau20[i]
    tableau20[i] = (r / 255., g / 255., b / 255.)

def latexify(fig_width=None, fig_height=None, columns=1, rows=1):
    if fig_width is None:
        fig_width = columns*3.39

    if fig_height is None:
        golden_mean = (sqrt(5)-1.0)/2.0    # Aesthetic ratio
        fig_height = rows * (fig_width / columns) * golden_mean # height in inches

    # MAX_HEIGHT_INCHES = 8.0
    # if fig_height > MAX_HEIGHT_INCHES:
    #     print("WARNING: fig_height too large:" + fig_height +
    #           "so will reduce to" + MAX_HEIGHT_INCHES + "inches.")
    #     fig_height = MAX_HEIGHT_INCHES

    params = {'backend': 'ps',
              'text.latex.preamble': ['\\usepackage{gensymb}'],
              'axes.labelsize': 8, # fontsize for x and y labels (was 10)
              'axes.titlesize': 8,
              'text.fontsize': 8, # was 10
              'legend.fontsize': 8, # was 10
              'xtick.labelsize': 8,
              'ytick.labelsize': 8,
              'text.usetex': True,
              'figure.figsize': [fig_width, fig_height],
              'font.family': 'serif'
    }

    matplotlib.rcParams.update(params)

def format_axes(ax):
    # Remove frame lines
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    # Ticks only on bottom and left
    ax.get_xaxis().tick_bottom()
    ax.get_yaxis().tick_left()

    for spine in ['left', 'bottom']:
        ax.spines[spine].set_color(SPINE_COLOR)
        ax.spines[spine].set_linewidth(0.5)

    ax.xaxis.set_ticks_position('bottom')
    ax.yaxis.set_ticks_position('left')

    for axis in [ax.xaxis, ax.yaxis]:
        axis.set_tick_params(direction='out', color=SPINE_COLOR)

    ax.set_xscale('log')
    ax.set_xlabel("Gap Length")

    ax.set_ylim([0.0, 1.0])

    return ax

def avg(l): return float(sum(l)) / len(l)
def median(l):
    if len(l) == 0: return 0
    if len(l) == 1: return l[0]

    s = sorted(l)
    m = int(len(l) / 2)
    if len(l) % 2 == 1:
        return s[m]
    else:
        return avg(s[m-1:m+1])

def plot_between(ax, unmapped, overlap, gapfiller, filter, steps=50, legend=True):
    lengths = sorted(filter[150].keys())
    smooth_lengths = np.logspace(log(min(lengths), 10), log(max(lengths), 10), steps)

    between = lambda d, f, i, j: [f(d[x]) for x in lengths if x >= i and x <= j]
    smooth = lambda d, f: [f(between(d, f, i, j)) for i, j in zip([0]+smooth_lengths, smooth_lengths+[float("inf")])]

    ax.plot(smooth_lengths, smooth(filter[150], median), '-',
        smooth_lengths, smooth(filter[1500], median), '-',
        smooth_lengths, smooth(filter[3000], median), '-',
        smooth_lengths, smooth(unmapped, median), ':',
        smooth_lengths, smooth(overlap, median), '--',
        smooth_lengths, smooth(gapfiller, median), '--')

    if legend:
        ax.legend(['Filter (150)', 'Filter (1500)', 'Filter (3000)',
            'Unmapped', 'Overlap', 'GapFiller'])

# Read scores
#          Recall  Precision  F-score
# unmapped   0        1         2
# overlap    3        4         5
# gapfiller  6        7         8
# filter     9        10        11
dds = [defaultdict(lambda: defaultdict(list)) for i in range(12)]

with open(sys.argv[1], 'r') as f:
  for l in f:
    # GAPLENGTH MEAN STDDEV OVERLAP UNMAPPED FILTER
    d = l.rstrip().split()

    length = int(d[0])
    mean = int(d[1])
    stddev = int(d[2])

    for i in range(12):
        dds[i][mean][length].append(float(d[i+3]))

def dictsum(a, b):
    c = {}
    for k in a.keys():
        c[k] = a[k] + b[k]
    return c

latexify(columns=1.5)
fig = plt.figure()
ax = fig.add_subplot(111)
ax.set_ylabel("Recall")
plot_between(format_axes(ax),
    dictsum(dictsum(dds[0][150], dds[0][1500]), dds[0][3000]),
    dictsum(dictsum(dds[3][150], dds[3][1500]), dds[3][3000]),
    dictsum(dictsum(dds[6][150], dds[6][1500]), dds[6][3000]),
    dds[9], sys.argv[2])
# ax.set_ylabel("Precision")
# plot_between(format_axes(ax),
#     dictsum(dictsum(dds[1][150], dds[1][1500]), dds[1][3000]),
#     dictsum(dictsum(dds[4][150], dds[4][1500]), dds[4][3000]),
#     dictsum(dictsum(dds[7][150], dds[7][1500]), dds[7][3000]),
#     dds[10], sys.argv[2])
# ax.set_ylabel("F-score")
# plot_between(format_axes(ax),
#     dictsum(dictsum(dds[2][150], dds[2][1500]), dds[2][3000]),
#     dictsum(dictsum(dds[5][150], dds[5][1500]), dds[5][3000]),
#     dictsum(dictsum(dds[8][150], dds[8][1500]), dds[8][3000]),
#     dds[11], sys.argv[2])
plt.tight_layout()
if len(sys.argv) == 4:
    plt.savefig(sys.argv[3])
else:
    plt.show()
