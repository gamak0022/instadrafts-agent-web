
"use client";
import React, { useState, useEffect, use } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { FileText, MessageSquare, Send, CheckCircle, ChevronLeft, Download, AlertCircle } from 'lucide-react';

export default function LawyerTaskDetail() {
  const { taskId } = useParams();
  const [taskDetail, setTaskDetail] = useState<any>(null);
  const [draft, setDraft] = useState("");
  const [attachments, setAttachments] = useState<any[]>([]);
  const [messages, setMessages] = useState<any[]>([]);
  const [infoMsg, setInfoMsg] = useState("");
  const [mounted, setMounted] = useState(false);
  const [saving, setSaving] = useState(false);
  const router = useRouter();

  const lawyerId = typeof window !== 'undefined' ? localStorage.getItem('lawyerId') : "";

  useEffect(() => {
    setMounted(true);
    fetchData();
  }, [taskId]);

  const fetchData = async () => {
    try {
      // We use the admin endpoint structure as lawyers are just internal users here
      const res = await fetch(`/api/v1/admin/task/${taskId}`);
      const data = await res.json();
      setTaskDetail(data);
      setDraft(data.case?.artifacts?.[0]?.contentText || "");
      
      const attRes = await fetch(`/api/v1/cases/${data.caseId}/attachments`, { headers: { 'x-user-role': 'LAWYER', 'x-user-id': lawyerId || "" } });
      setAttachments(await attRes.json());

      const msgRes = await fetch(`/api/v1/cases/${data.caseId}/messages`);
      setMessages(await msgRes.json());
    } catch (err) { console.error(err); }
  };

  const requestInfo = async () => {
    if (!infoMsg) return;
    await fetch(`/api/v1/cases/${taskDetail.caseId}/request-info`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'x-user-role': 'LAWYER', 'x-user-id': lawyerId || "" },
      body: JSON.stringify({ content: infoMsg })
    });
    setInfoMsg("");
    fetchData();
  };

  const submitToAdmin = async () => {
    await fetch(`/api/v1/lawyer/task/${taskId}/submit`, { method: 'POST' });
    router.push('/inbox');
  };

  if (!mounted) return null;
  if (!taskDetail) return <div className="p-20 text-center animate-pulse text-indigo-500 font-black uppercase tracking-widest">Loading Manifest...</div>;

  return (
    <div className="min-h-screen bg-slate-950 text-slate-200">
      <nav className="border-b border-slate-900 px-8 py-4 flex justify-between items-center sticky top-0 bg-slate-950/90 backdrop-blur-md z-50">
         <button onClick={() => router.push('/inbox')} className="text-slate-500 hover:text-white flex items-center gap-2 text-[10px] font-black uppercase tracking-widest">
            <ChevronLeft className="w-3 h-3" /> Dashboard
         </button>
         <div className="px-5 py-1.5 bg-indigo-600/10 border border-indigo-600/20 text-indigo-400 font-black uppercase text-[10px] rounded-full tracking-widest">
            {taskDetail.case.status}
         </div>
      </nav>

      <div className="max-w-7xl mx-auto px-8 py-12 grid grid-cols-1 lg:grid-cols-12 gap-12">
        {/* EDITOR AREA */}
        <div className="lg:col-span-8 space-y-8">
           <section className="bg-slate-900 border border-slate-800 p-10 rounded-[2.5rem] shadow-2xl">
              <h2 className="text-xs font-black uppercase tracking-widest text-slate-500 mb-8 flex items-center gap-2"><FileText className="w-4 h-4"/> Draft Review</h2>
              <textarea 
                value={draft}
                onChange={e => setDraft(e.target.value)}
                className="w-full h-[600px] bg-slate-950 border border-slate-800 p-10 rounded-3xl font-serif text-lg leading-relaxed shadow-inner"
              />
              <div className="mt-8 flex gap-4">
                 <button onClick={submitToAdmin} className="flex-1 bg-emerald-600 py-4 rounded-2xl font-black uppercase text-xs tracking-widest flex items-center justify-center gap-2 shadow-xl shadow-emerald-600/20 hover:bg-emerald-500 transition-all">
                    <CheckCircle className="w-4 h-4" /> Approve & Push
                 </button>
              </div>
           </section>
        </div>

        {/* SIDEBAR: DOCUMENTS & LOOP */}
        <aside className="lg:col-span-4 space-y-8">
           <section className="bg-slate-900 border border-slate-800 p-8 rounded-[2rem]">
              <h2 className="text-xs font-black uppercase tracking-widest text-slate-500 mb-8">Secure Attachments</h2>
              <div className="space-y-3">
                 {attachments.map(a => (
                    <div key={a.id} className="flex items-center justify-between p-4 bg-slate-950 border border-slate-800 rounded-2xl group hover:border-indigo-500 transition-all">
                       <div className="flex items-center gap-3">
                          <FileText className="w-5 h-5 text-indigo-500" />
                          <div>
                             <p className="text-xs font-bold text-white truncate max-w-[120px]">{a.fileName}</p>
                             <p className="text-[8px] font-black uppercase text-slate-600">{(a.size/1024).toFixed(1)} KB</p>
                          </div>
                       </div>
                       <a href={`/api/v1/attachments/stream?key=${a.storageKey}`} target="_blank" className="p-2 hover:bg-slate-800 rounded-lg text-slate-500 hover:text-white transition-all">
                          <Download className="w-4 h-4" />
                       </a>
                    </div>
                 ))}
                 {attachments.length === 0 && <p className="text-[10px] text-slate-700 font-bold uppercase text-center py-4">No Shared Files</p>}
              </div>
           </section>

           <section className="bg-slate-900 border border-slate-800 p-8 rounded-[2rem]">
              <h2 className="text-xs font-black uppercase tracking-widest text-slate-500 mb-8 flex items-center gap-2"><MessageSquare className="w-4 h-4"/> Client Comm Loop</h2>
              <div className="space-y-4 max-h-[300px] overflow-y-auto mb-6 pr-2">
                 {messages.map(m => (
                    <div key={m.id} className={`p-4 rounded-2xl text-xs ${m.senderRole === 'CLIENT' ? 'bg-slate-950 text-indigo-400' : 'bg-indigo-600/10 text-indigo-300'}`}>
                       <p className="font-bold mb-1 uppercase text-[8px] opacity-50">{m.senderRole}</p>
                       {m.content}
                    </div>
                 ))}
              </div>
              <div className="space-y-3">
                 <textarea 
                   value={infoMsg} onChange={e => setInfoMsg(e.target.value)}
                   className="w-full h-24 bg-slate-950 border border-slate-800 p-3 rounded-xl text-xs font-medium" 
                   placeholder="Request additional information..."
                 />
                 <button onClick={requestInfo} className="w-full bg-slate-800 hover:bg-indigo-600 py-3 rounded-xl font-black uppercase text-[10px] tracking-widest transition-all flex items-center justify-center gap-2">
                    <AlertCircle className="w-3 h-3"/> Request Info
                 </button>
              </div>
           </section>
        </aside>
      </div>
    </div>
  );
}
