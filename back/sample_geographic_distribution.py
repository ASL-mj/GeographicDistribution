from pathlib import Path

import geopandas as gpd
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


BASE_DIR = Path(__file__).resolve().parent
INPUT_FILE = BASE_DIR / "input" / "经纬度信息.txt"
DATA_DIR = BASE_DIR / "data"
OUTPUT_DIR = BASE_DIR / "output"
OUTPUT_PDF = OUTPUT_DIR / "黄连样本地理分布图.pdf"
OUTPUT_PNG = OUTPUT_DIR / "黄连样本地理分布图.png"

# 地图颜色
MAP_SEA = "#B3D9FF"
MAP_FILL = "#F5F5DD"
WORLD_MAP_COLOR = "#D9D9D9"
CHINA_MAP_COLOR = "#CACACA"

# 地图范围
LONGITUDE_RANGE = (96, 123)
LATITUDE_RANGE = (22, 33)

# 输出尺寸
OUTPUT_WIDTH = 10
OUTPUT_HEIGHT = 6


def main() -> None:
    sample_data = pd.read_csv(INPUT_FILE, sep="\t")
    world = gpd.read_file(DATA_DIR / "world.shp")
    china_mainland = gpd.read_file(DATA_DIR / "china_mainland.shp")
    taiwan = gpd.read_file(DATA_DIR / "taiwan.shp")

    world = world[~world["NAME"].isin(["China", "Taiwan"])]
    china_mainland = china_mainland.rename(columns={"NAME_1": "name"})
    china_full = pd.concat(
        [china_mainland[["name", "geometry"]], taiwan[["name", "geometry"]]],
        ignore_index=True,
    )

    fig, ax = plt.subplots(figsize=(OUTPUT_WIDTH, OUTPUT_HEIGHT))
    ax.set_facecolor(MAP_SEA)

    world.plot(ax=ax, color=MAP_FILL, edgecolor=WORLD_MAP_COLOR, linewidth=0.1)
    china_full.plot(ax=ax, color=MAP_FILL, edgecolor=CHINA_MAP_COLOR, linewidth=0.1)

    unique_species = sample_data["Species"].unique()
    colors = plt.cm.tab10(np.linspace(0, 1, len(unique_species)))
    for index, species in enumerate(unique_species):
        subset = sample_data[sample_data["Species"] == species]
        ax.scatter(
            subset["longitude"],
            subset["latitude"],
            label=species,
            color=colors[index],
            s=20,
            zorder=5,
        )

    ax.set_xlim(LONGITUDE_RANGE)
    ax.set_ylim(LATITUDE_RANGE)

    xticks = np.arange(LONGITUDE_RANGE[0], LONGITUDE_RANGE[1] + 1, 5)
    yticks = np.arange(LATITUDE_RANGE[0], LATITUDE_RANGE[1] + 1, 2)
    ax.set_xticks(xticks)
    ax.set_xticklabels([f"{int(value)}°E" for value in xticks])
    ax.set_yticks(yticks)
    ax.set_yticklabels([f"{int(value)}°N" for value in yticks])

    ax.set_xlabel("Longitude")
    ax.set_ylabel("Latitude")
    ax.grid(False)
    ax.legend(title="", loc="center left", bbox_to_anchor=(1.02, 0.5))
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    plt.tight_layout()
    plt.savefig(OUTPUT_PDF, bbox_inches="tight")
    plt.savefig(OUTPUT_PNG, bbox_inches="tight", dpi=300)

    print(f"地图绘制完成：{OUTPUT_PDF}")
    print(f"地图绘制完成：{OUTPUT_PNG}")


if __name__ == "__main__":
    main()
