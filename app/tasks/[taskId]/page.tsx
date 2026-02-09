export default function AgentTaskDetail({params}:{params:{taskId:string}}){
  return (
    <main style={{padding:24}}>
      <h1 style={{fontSize:22,fontWeight:900}}>Task: {params.taskId}</h1>
      <p style={{opacity:.75,marginTop:8}}>(Scaffold) Checklist + OTP + uploads + updates.</p>
    </main>
  );
}
