
// VolumeRenderingDlg.cpp : implementation file
//

#include "stdafx.h"
#include "VolumeRendering_cp1.h"
#include "VolumeRenderingDlg.h"
#include "afxdialogex.h"
#include "stdio.h"
#include <iostream>

#include "RawDataProcessor.h"
#include "TranformationMgr.h"
using namespace std;
#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CAboutDlg dialog used for App About

class CAboutDlg : public CDialogEx
{
public:
    CAboutDlg();

// Dialog Data
    enum { IDD = IDD_ABOUTBOX };

    protected:
    virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Implementation
protected:
    DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
    CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()


// CVolumeRenderingDlg dialog




CVolumeRenderingDlg::CVolumeRenderingDlg(CWnd* pParent /*=NULL*/)
    : CDialogEx(CVolumeRenderingDlg::IDD, pParent)
{
    m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
    m_pRawDataProc = new CRawDataProcessor;
    m_pTransform = new CTranformationMgr;

}

void CVolumeRenderingDlg::DoDataExchange(CDataExchange* pDX)
{
    CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CVolumeRenderingDlg, CDialogEx)
    ON_WM_SYSCOMMAND()
    ON_WM_PAINT()
    ON_WM_QUERYDRAGICON()
    ON_WM_SIZE()
    ON_WM_CREATE()
    ON_WM_TIMER()
    ON_WM_MOUSEMOVE()
    ON_WM_LBUTTONDOWN()
    ON_WM_ERASEBKGND()
END_MESSAGE_MAP()


// CVolumeRenderingDlg message handlers

BOOL CVolumeRenderingDlg::OnInitDialog()
{
    CDialogEx::OnInitDialog();

    // Add "About..." menu item to system menu.

    // IDM_ABOUTBOX must be in the system command range.
    ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
    ASSERT(IDM_ABOUTBOX < 0xF000);

    CMenu* pSysMenu = GetSystemMenu(FALSE);
    if (pSysMenu != NULL)
    {
        BOOL bNameValid;
        CString strAboutMenu;
        bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
        ASSERT(bNameValid);
        if (!strAboutMenu.IsEmpty())
        {
            pSysMenu->AppendMenu(MF_SEPARATOR);
            pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
        }
    }

    // Set the icon for this dialog.  The framework does this automatically
    //  when the application's main window is not a dialog
    SetIcon(m_hIcon, TRUE);			// Set big icon
    SetIcon(m_hIcon, FALSE);		// Set small icon
	LPCTSTR str;
	CString c;
	CFile in;
	char *t = "name.txt";
	c = t;
	str = c;
	if (!in.Open(str, CFile::modeRead))
	{
		return false;
	}
	char *name;
	int bufferLength = in.GetLength();
	name = new char[bufferLength+1];
	in.Read(name, bufferLength);
	name[bufferLength] = '\0';

	c = name;
	str = LPCTSTR(c);
	
	SetWindowText(str);

    CFileDialog objOpenFile(TRUE);
    if( IDOK != TRUE /*IDOK !=  objOpenFile.DoModal()*/)
    {
        exit(0);
    }

    if( !m_pRawDataProc->ReadFile(  _T("render.dat")/*objOpenFile.GetPathName()*/, 
                                    512, 512)) //����ͼƬ����
    {
        AfxMessageBox( _T( "Failed to read the data" ));
    }


    return TRUE;  // return TRUE  unless you set the focus to a control
}

void CVolumeRenderingDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
    if ((nID & 0xFFF0) == IDM_ABOUTBOX)
    {
        CAboutDlg dlgAbout;
        dlgAbout.DoModal();
    }
    else
    {
        CDialogEx::OnSysCommand(nID, lParam);
    }
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CVolumeRenderingDlg::OnPaint()
{
    CPaintDC dc(this);
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CVolumeRenderingDlg::OnQueryDragIcon()
{
    return static_cast<HCURSOR>(m_hIcon);
}



void CVolumeRenderingDlg::OnSize(UINT nType, int cx, int cy)
{
    CDialogEx::OnSize(nType, cx, cy);
    m_Renderer.Resize( cx, cy );
    Invalidate();
}


int CVolumeRenderingDlg::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
    if (CDialogEx::OnCreate(lpCreateStruct) == -1)
        return -1;

    mhContext = ::GetDC( m_hWnd );
    if( !m_Renderer.Initialize( mhContext, m_pRawDataProc, m_pTransform ))
    {
        ::MessageBox( 0, _T( "Failed to initialze the renderer !"), _T( "Renderer" ), MB_OK );
        exit(0);
    }
    return 0;
}


void CVolumeRenderingDlg::OnTimer(UINT_PTR nIDEvent)
{
    // m_Renderer.Rotate();
    CDialogEx::OnTimer(nIDEvent);
    Invalidate();
}


void CVolumeRenderingDlg::OnMouseMove(UINT nFlags, CPoint point)
{
    if( nFlags & MK_LBUTTON )
    {
        m_pTransform->Rotate( mRotReference.y-point.y, mRotReference.x-point.x, 0 );
        mRotReference = point;
    }
    CDialogEx::OnMouseMove(nFlags, point);
    Invalidate();
}


void CVolumeRenderingDlg::OnLButtonDown(UINT nFlags, CPoint point)
{
    mRotReference = point;
    CDialogEx::OnLButtonDown(nFlags, point);
}


BOOL CVolumeRenderingDlg::OnEraseBkgnd(CDC* pDC)
{
    m_Renderer.Render();
    SwapBuffers( mhContext );
    return TRUE;
}
