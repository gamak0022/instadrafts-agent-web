"use client";
import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
export default function LawyerInbox() {
    const [tasks, setTasks] = useState([]);
    const [mounted, setMounted] = useState(false);
    const [loading, setLoading] = useState(true);
    const router = useRouter();
    useEffect(() => {
        setMounted(true);
        const id = localStorage.getItem('lawyerId');
        if (!id) {
            router.push('/login');
            return;
        }
        fetch(`/api/v1/lawyer/tasks?lawyerId=${id}`)
            .then(res => res.json())
            .then(data => {
            setTasks(data || []);
            setLoading(false);
        })
            .catch(() => setLoading(false));
    }, [router]);
    if (!mounted)
        return null;
    return (<div className="container">
      <header className="header">
        <h1>Review Inbox</h1>
        <button onClick={() => { localStorage.removeItem('lawyerId'); router.push('/login'); }}>Logout</button>
      </header>
      
      {loading ? <p>Loading tasks...</p> : (<div className="task-list">
          {tasks.length === 0 ? <p>No tasks assigned.</p> : tasks.map(task => (<Link href={`/task/${task.taskId}`} key={task.taskId} className="task-card">
              <div>
                <h3>{task.caseId}</h3>
                <span className={`status-badge status-${task.status.toLowerCase()}`}>{task.status}</span>
              </div>
              <p className="task-date">{new Date(task.createdAt).toLocaleDateString()}</p>
            </Link>))}
        </div>)}
    </div>);
}
