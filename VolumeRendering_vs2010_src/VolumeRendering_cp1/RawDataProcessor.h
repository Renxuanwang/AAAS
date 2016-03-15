#pragma once
class CRawDataProcessor
{
public:
    CRawDataProcessor(void);
    virtual ~CRawDataProcessor(void);
    // Call this only after the open gl is initialized.
    bool ReadFile(LPCTSTR lpDataFile_i, int nWidth_i, int nHeight_i );
    int GetTexture3D()
    {
        return m_nTexId;
    }
    const int GetWidth()
    {
        return m_uImageWidth;
    }
    const int GetHeight()
    {
        return m_uImageHeight;
    }
    const int GetDepth()
    {
        return m_uImageCount;
    }
	void countSet(int cnt)
	{
		m_uImageCount = cnt;
	}

private:

    int m_uImageCount;
    int m_uImageWidth;
    int m_uImageHeight;
    int m_nTexId;
};

