import numpy as np
import pandas as pd
from datetime import datetime
import calendar
from fastdtw import fastdtw
from scipy.spatial.distance import euclidean
from sklearn.metrics.pairwise import cosine_similarity
from frechetdist import frdist
from scipy.spatial.distance import directed_hausdorff
from tslearn.metrics import lcss

def get_start_end_dates(year, months):
    start_date = datetime(year, months[0], 1).strftime('%Y-%m-%d')
    last_month = months[-1]
    last_day = calendar.monthrange(year, last_month)[1]
    end_date = datetime(year, last_month, last_day).strftime('%Y-%m-%d')
    return start_date, end_date

def ComputeEuclideanDistance(X,Y):
    # the smaller the euclidean distance, the more similar the two time series are
    return np.sqrt(np.sum((X-Y)**2))


def ComputeDTWDistance(X,Y):
    # the smaller the dtw distance, the more similar the two time series are
    distance,path = fastdtw(X,Y, dist=euclidean)
    return distance,path

def ComputeCosineSimilarity(X,Y):
    # the range of cosine similarity is [-1,1]
    # the closer the value is to 1, the more similar the two time series are
    # is not sutable for negative values
    # only consider direction, not magnitude
    cos_sim = cosine_similarity([X], [Y])[0][0]
    return cos_sim

def ComputeFrechetDistance(X,Y):
    # the smaller the frechet distance, the more similar the two time series are
    # the input should be as [[1,1], [2,1], [2,2]] and [[2,2], [0,1], [2,4]]
    return frdist(X,Y)

def ComputeHausdorffDistance(X,Y):
    # the smaller the hausdorff distance, the more similar the two time series are
    # the input should be as [[1,1], [2,1], [2,2]] and [[2,2], [0,1], [2,4]]
    return directed_hausdorff(X,Y)

def ComputeLongestCommonSubsequenceSimilarity(X,Y):
    # the larger the lcss_score the more similar the two time series are
    lcss_score = lcss(X,Y)
    return lcss_score

def ComputeSimilarity(target_timeseries:pd.Series,reference_timeseries:pd.Series)->tuple:
    # Get months from the target timeseries
    months = target_timeseries.index.month
    # Get the years from the reference timeseries
    years = reference_timeseries.index.year
    tar_list = target_timeseries.values
    tar_vec = []
    for i in range(len(tar_list)):
        point = [i+1,tar_list[i]]
        tar_vec.append(point)
    year_list = []
    eud_dis_list = []
    dtw_dis_list = []
    fre_dis_list = []
    haus_dis_list = []
    lcss_score_list = []
    cos_sim_list = []
    sim_score_list = []

    

    for year in set(years):
        start_date,end_date = get_start_end_dates(year, months)
        ref_list = reference_timeseries[start_date:end_date].values
        # print(year,tar_list,ref_list)
        # compute the euclidean distance
        euc_dis = ComputeEuclideanDistance(tar_list,ref_list)
        # compute the dtw distance
        ref_vec = []
        for i in range(len(ref_list)):
            point = [i+1,ref_list[i]]
            ref_vec.append(point)
        dtw_dis,path = ComputeDTWDistance(np.array(tar_vec),np.array(ref_vec))
        # compute the edit distance
        cos_sim =  ComputeCosineSimilarity(list(tar_list),list(ref_list))
        # compute the frechet distance
        fre_dis = ComputeFrechetDistance(np.array(tar_vec),np.array(ref_vec))
        # compute the hausdorff distance
        haus_dis = ComputeHausdorffDistance(np.array(tar_vec),np.array(ref_vec))
        # compute the lcs similarity
        lcss_score = ComputeLongestCommonSubsequenceSimilarity(tar_list,ref_list)

        sim_score = (euc_dis+dtw_dis+fre_dis+haus_dis[0])/(lcss_score+cos_sim) # the smaller the score, the more similar the two time series are

        year_list.append(year)
        eud_dis_list.append(euc_dis)
        dtw_dis_list.append(dtw_dis)
        fre_dis_list.append(fre_dis)
        haus_dis_list.append(haus_dis[0])
        lcss_score_list.append(lcss_score)
        cos_sim_list.append(cos_sim)
        sim_score_list.append(sim_score)

    sim_df = pd.DataFrame(
        {'Euclidean Distance':eud_dis_list,
         'DTW Distance':dtw_dis_list,
         'Frechet Distance':fre_dis_list,
         'Hausdorff Distance':haus_dis_list,
         'Longest Common Subsequence Similarity':lcss_score_list,
         'Cosine Similarity':cos_sim_list,
         'Similarity Score':sim_score_list
        },index=year_list)
    
    score_sim_year = sim_df['Similarity Score'].idxmin()
    euc_sim_year = sim_df['Euclidean Distance'].idxmin()
    dtw_sim_year = sim_df['DTW Distance'].idxmin()
    fre_sim_year = sim_df['Frechet Distance'].idxmin()
    haus_sim_year = sim_df['Hausdorff Distance'].idxmin()
    lcss_sim_year = sim_df['Longest Common Subsequence Similarity'].idxmax()
    cos_sim_year = sim_df['Cosine Similarity'].idxmax()

    sim_year_dict = {
        'Similarity Score':score_sim_year,
        'Euclidean Distance':euc_sim_year,
        'DTW Distance':dtw_sim_year,
        'Frechet Distance':fre_sim_year,
        'Hausdorff Distance':haus_sim_year,
        'Longest Common Subsequence Similarity':lcss_sim_year,
        'Cosine Similarity':cos_sim_year
    }
    
    return sim_df,sim_year_dict


# for test
if __name__ == '__main__':
    df = pd.read_csv('D:/DataSpace/HydroMeteAnthropicDatabase/7.FilledRawMeteObsInfo/ChinaLandDailyMeteV3(InsertSolarRadiation)/玛曲.csv',parse_dates=['DATE'],index_col=['DATE'])
    df_precp = df['P2020(mm)']
    df_precp = df_precp.resample('ME').sum()
    df_precp_tar = df_precp['2015-06-01':'2015-12-31']
    df_precp_ref = df_precp[:'2014-12-31']
    # print(df_precp_ref)
    df,sim_year_dict = ComputeSimilarity(df_precp_tar,df_precp_ref)
    print(sim_year_dict)