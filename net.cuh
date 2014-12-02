#ifndef _NET_CUH_
#define _NET_CUH_

#include "cuMatrix.h"
#include <vector>
#include <stdio.h>
#include <cuda_runtime.h>
#include "cuMatrixVector.h"
/*�������*/
typedef struct cuConvKernel{
	cuMatrix<double>* W;
	cuMatrix<double>* b;
	cuMatrix<double>* Wgrad;
	cuMatrix<double>* bgrad;
	void clear()
	{
		delete W;
		delete b;
		delete Wgrad;
		delete bgrad;
	}
}cuConvK;

/*�����*/
typedef struct cuConvLayer{
	std::vector<cuConvK> layer;
	double **h_w;
	double **d_w;
	double **h_wgrad;
	double **d_wgrad;
	double **h_b;
	double **d_b;
	double **h_bgrad;
	double **d_bgrad;

	void init();
	void clear(){
		for(int i = 0; i < layer.size(); i++) 
			layer[i].clear();

		layer.clear();

		free(h_w);
		free(h_wgrad);		
		free(h_b);
		free(h_bgrad);

		cudaFree(d_w);
		cudaFree(d_wgrad);
		cudaFree(d_b);	
		cudaFree(d_bgrad);
	}
}cuCvl;


/*�м������*/
typedef struct cuNetwork{
	cuMatrix<double>* W;
	cuMatrix<double>* b;
	cuMatrix<double>* Wgrad;
	cuMatrix<double>* bgrad;
	cuMatrix<double>* dropW;
	cuMatrix<double>* afterDropW;
	void clear()
	{
		delete W;
		delete b;
		delete Wgrad;
		delete bgrad;
		delete dropW;
		delete afterDropW;
	}
}cuNtw;

/*����㣬����softmax�ع�*/
typedef struct cuSoftmaxRegession{
	cuMatrix<double>* Weight;
	cuMatrix<double>* Wgrad;
	cuMatrix<double>* b;
	cuMatrix<double>* bgrad;
	cuMatrix<double>* cost;
	void clear()
	{
		delete Weight;
		delete Wgrad;
		delete b;
		delete bgrad;
		delete cost;
	}
}cuSMR;

/*
	function ��init network
	parameter��
	vector<Cvl> &ConvLayers      convolution
	vector<Ntw> &HiddenLayers	 hidden
	SMR &smr					 softmax
	int imgDim					 total pixel 
	int nsamples			     number of samples
*/
void cuConvNetInitPrarms(std::vector<cuCvl> &ConvLayers,
	std::vector<cuNtw> &HiddenLayers,
	cuSMR &smr,
	int imgDim,
	int nsamples,
	int nclasses);

void cuReadConvNet(std::vector<cuCvl> &ConvLayers,
	std::vector<cuNtw> &HiddenLayers, 
	cuSMR &smr, 
	int imgDim, 
	int nsamples, 
	char* path,
	int nclasses);

/*
	�������ܣ��������ѵ��
	����������
	vector<Mat> &x            �������ѵ������
	Mat &y                    ��ѵ��������Ӧ�ı�ǩ
	vector<Cvl> &CLayers      �������
	vector<Ntw> &HiddenLayers �����ز�
	SMR &smr				  ��softMax��
	double lambda			  ����������
	vector<Mat>&testX		  �����Լ���
	Mat& testY				  �����Լ��ϱ�ǩ
	int imgDim				  ��ÿ��ͼƬ�����ܺ�
	int nsamples              ��ѵ����������
*/

void cuTrainNetwork(cuMatrixVector<double>&x, 
	cuMatrix<double>*y , 
	std::vector<cuCvl> &CLayers,
	std::vector<cuNtw> &HiddenLayers, 
	cuSMR &smr,
	double lambda, 
	cuMatrixVector<double>& testX,
	cuMatrix<double>* testY,
	int nsamples,
	int batch,
	int ImgSize,
	int nclasses,
	cublasHandle_t handle);

void cuInitCNNMemory(
	int batch,
	cuMatrixVector<double>& trainX, 
	cuMatrixVector<double>& testX,
	std::vector<cuCvl>& ConvLayers,
	std::vector<cuNtw>& HiddenLayers,
	cuSMR& smr,
	int ImgSize,
	int nclasses);

int cuPredictNetwork(cuMatrixVector<double>& x, 
	cuMatrix<double>*y , 
	std::vector<cuCvl> &CLayers,
	std::vector<cuNtw> &HiddenLayers, 
	cuSMR &smr,
	double lambda, 
	cuMatrixVector<double>& testX,
	cuMatrix<double>* testY, 
	cuMatrix<double>* predict,
	int imgDim, 
	int nsamples,
	int batch,
	int ImgSize,
	int nclasses,
	cublasHandle_t handle);


void cuFreeConvNet(std::vector<cuCvl> &ConvLayers,
	std::vector<cuNtw> &HiddenLayers,
	cuSMR &smr);

void cuClearCorrectCount();

void cuFreeCNNMemory(
	int batch,
	cuMatrixVector<double>&trainX, 
	cuMatrixVector<double>&testX,
	std::vector<cuCvl>&ConvLayers,
	std::vector<cuNtw>&HiddenLayers, 
	cuSMR &smr);

int cuPredictAdd(cuMatrix<double>* predict, cuMatrix<double>* testY, int batch, int ImgSize, int nclasses);
void cuShowInCorrect(cuMatrixVector<double>&testX, cuMatrix<double>* testY, int ImgSize, int nclasses);
#endif