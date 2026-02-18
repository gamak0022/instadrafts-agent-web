"use client";
import React, { useState } from 'react';
import { DollarSign } from 'lucide-react';
export default function PayoutsPage() {
    const [payouts, setPayouts] = useState([
        { id: '1', amount: 2500, status: 'PAID', date: '2025-05-10', caseId: 'case_a1b2' },
        { id: '2', amount: 2500, status: 'PENDING', date: '2025-05-12', caseId: 'case_c3d4' }
    ]);
    const total = payouts.reduce((acc, p) => p.status === 'PAID' ? acc + p.amount : acc, 0);
    return (<div className="min-h-screen bg-slate-950 text-slate-200 p-12">
      <div className="max-w-4xl mx-auto">
        <header className="mb-16 flex justify-between items-end">
           <div>
              <h1 className="text-4xl font-black italic uppercase tracking-tighter text-white">Payout Dashboard</h1>
              <p className="text-slate-500 font-mono text-xs mt-2 uppercase">Verified Commission Log</p>
           </div>
           <div className="bg-slate-900 border border-slate-800 p-6 rounded-3xl text-right min-w-[240px]">
              <span className="block text-[10px] font-black uppercase text-indigo-500 mb-1 tracking-widest">Global Payouts</span>
              <span className="text-4xl font-black text-white italic">₹{(total / 100).toLocaleString()}</span>
           </div>
        </header>

        <div className="space-y-4">
           {payouts.map(p => (<div key={p.id} className="bg-slate-900/50 border border-slate-800 p-8 rounded-3xl flex items-center justify-between group">
                 <div className="flex gap-8 items-center">
                    <div className={`w-14 h-14 rounded-2xl flex items-center justify-center ${p.status === 'PAID' ? 'bg-emerald-500/10 text-emerald-500 border border-emerald-500/20' : 'bg-orange-500/10 text-orange-500 border border-orange-500/20'}`}>
                       <DollarSign className="w-7 h-7"/>
                    </div>
                    <div>
                       <div className="flex items-center gap-3 mb-1">
                          <span className="text-[10px] font-black uppercase text-slate-500 tracking-tighter">Node_{p.caseId}</span>
                          <span className={`text-[8px] font-black px-2 py-0.5 rounded border uppercase ${p.status === 'PAID' ? 'bg-emerald-500/10 border-emerald-500/20 text-emerald-500' : 'bg-orange-500/10 border-orange-500/20 text-orange-500'}`}>{p.status}</span>
                       </div>
                       <h3 className="font-bold text-lg uppercase italic tracking-tight">Legal Review Commission</h3>
                    </div>
                 </div>
                 <div className="text-right">
                    <p className="text-[10px] font-black uppercase text-slate-600 mb-1">Received On</p>
                    <p className="text-xs font-mono text-slate-400 mb-4">{p.date}</p>
                    <p className="text-2xl font-black text-white italic">₹{p.amount / 100}</p>
                 </div>
              </div>))}
        </div>
      </div>
    </div>);
}
