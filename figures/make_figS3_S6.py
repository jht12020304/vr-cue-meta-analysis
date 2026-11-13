from pathlib import Path
import json
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from PIL import Image
plt.rcParams.update({"font.family":"Arial","font.size":8,"axes.linewidth":.8,"pdf.fonttype":42})
BLUE="#222222";GREY="#666666"
def plot(rows,path,dimensions,xlim,ticks,footnote,main_reference=None):
 fig=plt.figure(figsize=((dimensions[0]+.01)/300,(dimensions[1]+.01)/300),dpi=300)
 n=len(rows);ax=fig.add_axes([.515,.23 if n<5 else .135,.24,.66 if n<5 else .76])
 for i,(label,g,lo,hi,txt,recon) in enumerate(rows):
  y=n-1-i;c=BLUE if recon else GREY
  if lo is not None:ax.plot([lo,hi],[y,y],color=c,lw=1.2)
  if g is not None:ax.plot(g,y,'o',color=c,ms=4.5)
  ax.text(-.055,y,label,transform=ax.get_yaxis_transform(),ha='right',va='center',fontsize=7.5,color=c,clip_on=False)
  ax.text(1.055,y,txt,transform=ax.get_yaxis_transform(),ha='left',va='center',fontsize=7.1,color=c,clip_on=False)
 ax.axvline(0,color='#999999',lw=.6)
 if n>4:ax.axvline(main_reference,color=BLUE,lw=.6,ls=(0,(2,2)),alpha=.6)
 ax.set_xlim(*xlim);ax.set_ylim(-.65,n-.35)
 ax.set_yticks([]);ax.set_xticks(ticks);ax.tick_params(axis='x',labelsize=7)
 ax.set_xlabel("Hedges’ g",fontsize=8,labelpad=2);ax.spines[['top','left','right']].set_visible(False)
 fig.text(.015,.97,'Black: updated analyses   |   Gray: previously reported analyses',fontsize=8,color='#222222',va='top')
 fig.text(.015,.015,footnote,fontsize=7,color='#333333',va='bottom')
 fig.savefig(path,dpi=300,facecolor='white');plt.close(fig)
 if path.suffix=='.png':assert Image.open(path).size==tuple(dimensions)
base=Path(__file__).resolve().parent; out=base.parent/"results"
data=json.loads((base/"figure_data.json").read_text())
for f in data["figures"]:
    for extension in ["png","pdf"]:
        plot(f["rows"],out/(f["name"]+"."+extension),f["dimensions"],f["xlim"],f["ticks"],f["footnote"],f["main_reference"])
