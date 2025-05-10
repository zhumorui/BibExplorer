// 注：彻底由 content 脚本来写剪贴板
(function() {
    const btn = document.createElement('button');
    btn.textContent = 'Import to bibfzf';
    btn.style = 'position:fixed;top:10px;right:10px;z-index:1000;padding:6px 8px;background:#007bff;color:#fff;border:none;border-radius:4px;cursor:pointer;';
    document.body.appendChild(btn);
  
    btn.addEventListener('click', async () => {
      try {
        // 从 URL 提取 arXiv ID
        const m = window.location.pathname.match(/\/abs\/([0-9\.v]+)$/);
        if (!m) throw new Error('Cannot parse arXiv ID from URL');
        const arxivId = m[1];
  
        // 直接构造 BibTeX 链接并 fetch
        const bibUrl = `https://arxiv.org/bibtex/${arxivId}`;
        const bibText = await fetch(bibUrl).then(r => r.text());
  
        // 解析 cite-key
        const keyMatch = bibText.match(/@\w+\{([^,]+),/);
        const citeKey = keyMatch ? keyMatch[1] : arxivId;
  
        // **剪贴板写入：放在 content 脚本中**
        await navigator.clipboard.writeText(bibText);
        console.log('BibTeX copied to clipboard');
  
        // 通知 background 下载 PDF
        const pdfUrl = `https://arxiv.org/pdf/${arxivId}.pdf`;
        chrome.runtime.sendMessage({ citeKey, pdfUrl });
      } catch (e) {
        console.error(e);
        alert('Import to bibfzf failed:\n' + e.message);
      }
    });
  })();
  