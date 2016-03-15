#include "StdAfx.h"
#include "RawDataProcessor.h"

#include <GL\glew.h>

CRawDataProcessor::CRawDataProcessor(void) : 
m_uImageWidth(0)
,m_uImageHeight(0)
,m_uImageCount(0)
,m_nTexId(0)
{
}


CRawDataProcessor::~CRawDataProcessor(void)
{
    // If not initialized, then this will be zero. So no checking is needed.
    if( 0 != m_nTexId )
    {
        glDeleteTextures( 1, (GLuint*)&m_nTexId );
    }
}

bool CRawDataProcessor::ReadFile(LPCTSTR lpDataFile_i, int nWidth_i, int nHeight_i )
{
    CFile Medfile;
    if( !Medfile.Open(lpDataFile_i ,CFile::modeRead ))
    {
        return false;
    }

    // File has only image data. The dimension of the data should be known.

    m_uImageWidth = nWidth_i;
    m_uImageHeight = nHeight_i;


    // Holds the luminance buffer
   // char* chBuffer = new char[ m_uImageWidth*m_uImageHeight*m_uImageCount ];
	long long bufferLength = Medfile.GetLength();
	char *chBuffer = new char[bufferLength];
	long long pos = 0;
	int cnt = bufferLength / (512 * 512 * 2);
	countSet(cnt);
    if( !chBuffer)
    {
        return false;
    }
    // Holds the RGBA buffer
    char* pRGBABuffer = new char[ bufferLength*2 ];
    if( !pRGBABuffer)
    {
        return false;
    }

    Medfile.Read(chBuffer, bufferLength);

    // Convert the data to RGBA data.
    // Here we are simply putting the same value to R, G, B and A channels.
    // Usually for raw data, the alpha value will be constructed by a threshold value given by the user 

    for( long long nIndx = 0; nIndx < bufferLength-1; nIndx+= 1 )
    {

		if (chBuffer[nIndx] == ' ' || chBuffer[nIndx] == '\t' || chBuffer[nIndx] == '\n') continue;
		else{
			if (chBuffer[nIndx] == '1'){   //Æ¤ÏÂÖ¬·¾
				pRGBABuffer[pos * 4] = 25; //r
				pRGBABuffer[pos * 4 + 1] = 25;//g
				pRGBABuffer[pos * 4 + 2] = 112;//b
				pRGBABuffer[pos * 4 + 3] = 255; //a
				pos++;
			}
			else if (chBuffer[nIndx] == '2'){   //ÌåÄÚÖ¬·¾
				pRGBABuffer[pos * 4] = 138;
				pRGBABuffer[pos * 4 + 1] = 43;
				pRGBABuffer[pos * 4 + 2] = 226;
				pRGBABuffer[pos * 4 + 3] = 255;
				pos++;
			}
			else if (chBuffer[nIndx] == '3'){
				pRGBABuffer[pos * 4] = 125;
				pRGBABuffer[pos * 4 + 1] = 255;
				pRGBABuffer[pos * 4 + 2] = 255;
				pRGBABuffer[pos * 4 + 3] = 0;
				pos++;
			}

			else if (chBuffer[nIndx] == '4'){
				pRGBABuffer[pos * 4] = 125;
				pRGBABuffer[pos * 4 + 1] = 125;
				pRGBABuffer[pos * 4 + 2] = 125;
				pRGBABuffer[pos * 4 + 3] = 0;
				pos++;
			}
		}
    }

    // If this function is getting called again for another data file.
    // Deleting and creating texture is not a good idea, 
    // we can use the glTexSubImage3D for better performance for such scenario.
    // I am not using that now :-)
    if( 0 != m_nTexId )
    {
        glDeleteTextures( 1, (GLuint*)&m_nTexId );
    }
    glGenTextures(1,(GLuint*)&m_nTexId );

    glBindTexture( GL_TEXTURE_3D, m_nTexId );
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_BORDER);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);


    glTexImage3D(GL_TEXTURE_3D, 0, GL_RGBA, m_uImageWidth, m_uImageHeight , m_uImageCount, 0,
        GL_RGBA, GL_UNSIGNED_BYTE, pRGBABuffer );
    glBindTexture( GL_TEXTURE_3D, 0 );

    delete[] chBuffer;
    delete[] pRGBABuffer;
    return true;
}