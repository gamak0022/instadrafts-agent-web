"use client";
import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
export default function LawyerLogin() {
    const [lawyerId, setLawyerId] = useState("");
    const [mounted, setMounted] = useState(false);
    const router = useRouter();
    useEffect(() => {
        setMounted(true);
    }, []);
    const handleLogin = (e) => {
        e.preventDefault();
        if (lawyerId.trim()) {
            localStorage.setItem('lawyerId', lawyerId);
            router.push('/inbox');
        }
    };
    if (!mounted)
        return null;
    return (<div className="login-container">
      <form onSubmit={handleLogin} className="login-card">
        <h1>Lawyer Portal</h1>
        <p>Enter your ID to access the dashboard</p>
        <input type="text" value={lawyerId} onChange={(e) => setLawyerId(e.target.value)} placeholder="Lawyer ID" required/>
        <button type="submit">Login</button>
      </form>
    </div>);
}
