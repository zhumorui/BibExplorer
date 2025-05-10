// background.js
chrome.runtime.onMessage.addListener((msg, sender) => {
    const { citeKey, pdfUrl } = msg;
    if (!citeKey || !pdfUrl) return;
  
    // **只负责下载**，不做任何剪贴板操作
    chrome.downloads.download({
      url: pdfUrl,
      filename: `papers/refs/${citeKey}.pdf`,
      conflictAction: 'uniquify'
    }, downloadId => {
      if (chrome.runtime.lastError) {
        console.error('Download failed', chrome.runtime.lastError);
      } else {
        console.log('Download started, id:', downloadId);
      }
    });
  });
  