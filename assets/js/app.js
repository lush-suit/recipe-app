function $(s, r=document){return r.querySelector(s)};function $all(s,r=document){return Array.from(r.querySelectorAll(s))}
function showToast(m){const t=$('#toast');if(!t)return;t.textContent=m;t.hidden=false;setTimeout(()=>t.hidden=true,1800);}
document.addEventListener('submit', e=>{const f=e.target;if(f.matches('.needs-validate')){const inv=$all('[required]',f).some(el=>!el.value.trim());if(inv){e.preventDefault();showToast('Please fill all required fields.')}}});
