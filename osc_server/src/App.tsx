import React, { useState, useEffect, useRef } from 'react'
import useWebSocket, { ReadyState } from 'react-use-websocket';
import Slider from '@mui/material/Slider';
import Grid from '@mui/material/Grid';
import Box from '@mui/material/Box';
import { BsCloudRainHeavy, BsSoundwave } from 'react-icons/bs';
import { BiVolumeMute } from 'react-icons/bi';
import { MdOutlineBubbleChart } from 'react-icons/md';
import { GiModernCity, GiHummingbird, GiSeagull, GiSwallow } from 'react-icons/gi';
import { FaDove, FaCrow } from 'react-icons/fa'
import Draggable from 'react-draggable';
import './App.css';
import {
  P5CanvasInstance,
  ReactP5Wrapper,
  SketchProps,
  Sketch
} from "react-p5-wrapper";

type MySketchProps = SketchProps & {
  speed: number;
  pause: boolean;
  clear: boolean;
  rainFall: boolean;
  underWater: boolean;
};

const sketch: Sketch<MySketchProps> = (p: P5CanvasInstance<MySketchProps>) => {
  let width: number = p.windowWidth;
  let height: number = window.screen.availHeight;
  let windowHeight: number = p.windowHeight;
  let sizeTras: number = p.min(width, height) / 870;
  let pause: boolean = false;
  let clear: boolean = false;
  // 雨
  let rainCount: number = 10;
  let maxRainCount: number = 10;
  let rainLengths: number[] = (new Array<number>(maxRainCount).fill(0)).map((d) => {return p.map(Math.random(), 0, 1, height*0.05, height*0.3)});
  let xs: number[] = (new Array<number>(maxRainCount).fill(0)).map((d) => {return width*Math.random()});
  let ys: number[] = (new Array<number>(maxRainCount).fill(0)).map((d) => {return height*Math.random()});
  let speed: number = 1;
  // 泡
  let awaCount: number = 10;
  let maxAwaCount: number = 10;
  let time = 0;
  let vertexCount = 100;
  let centerXs: number[] = (new Array<number>(maxAwaCount).fill(0)).map((d) => {return p.random(0, width)});
  let centerYs: number[] = (new Array<number>(maxAwaCount).fill(0)).map((d) => {return p.random(0, height)});
  let maxRadiuses: number[] = (new Array<number>(maxAwaCount).fill(0)).map((d) => {return p.random(p.min(width, height)/25, p.min(width, height)/5);});
  let awaSpeeds: number[] = (new Array<number>(maxAwaCount).fill(0)).map((d) => {return p.random(1.01, 1.06)});
  let rotateSpeeds: number[] = (new Array<number>(maxAwaCount).fill(0)).map((d) => {return p.random(0.0007, 0.003)});
  let shapeSpeeds: number[] = (new Array<number>(maxAwaCount).fill(0)).map((d) => {return p.random(0.01, 0.05)});
  let purupuruSpeeds: number[] = (new Array<number>(maxAwaCount).fill(0)).map((d) => {return p.random(0.1, 0.5)});
  let trueCircles: number[] = (new Array<number>(maxAwaCount).fill(1));
  let radiuses: number[] = (new Array<number>(maxAwaCount).fill(0));
  const getTheta = (i: number) => {return 2.*p.PI*i/vertexCount;}
  const getAwaX = (i: number, radius: number, centerX: number, purupuruSpeed: number, rotateSpeed: number, shapeSpeed: number) => {
    let theta = getTheta(i);
    return centerX + radius*0.01*(100.+p.map(p.noise(time*purupuruSpeed), 0, 1, 3, 5)*p.cos(p.noise(time*0.02)*10*p.noise(p.cos(theta+time*0.001),p.sin(theta+time*rotateSpeed),time*shapeSpeed)))*p.cos(theta);
  }
  const getAwaY = (i: number, radius: number, centerY: number, purupuruSpeed: number, rotateSpeed: number, shapeSpeed: number, trueCircle: number) => {
    let theta = getTheta(i);
    return centerY + radius*0.01*(100.+p.map(p.noise(time*purupuruSpeed), 0, 1, 3, 5)*p.cos(p.noise(time*0.02)*10*p.noise(p.cos(theta+time*0.001),p.sin(theta+time*rotateSpeed),time*shapeSpeed)))*p.sin(theta)*trueCircle;
  }

  p.setup = () => {
    p.createCanvas(width, height);
    p.fill(0);
    p.strokeWeight(p.min(sizeTras, 1)*0.4);
  };

  p.updateWithProps = (props: any) => {
    if (props.speed) {
      speed = props.speed;
    }
    if (props.pause!==undefined) {
      pause = props.pause;
    }
    if (props.clear!==undefined) {
      clear = props.clear;
    }
    if (props.rainFall!==undefined) {
      rainCount = maxRainCount * props.rainFall;
    }
    if (props.underWater!==undefined) {
      awaCount = maxAwaCount * props.underWater;
    }
  };

  p.draw = () => {
    if (clear) {
      p.clear(255, 255, 255, 255);
      pause = true;
      return;
    }
    if (pause) {return;}
    p.clear(255, 255, 255, 255); // 前に描画したものをクリア
    // 雨の描画
    if (rainCount>maxRainCount){rainCount=maxRainCount;}
    for (let i=0; i<rainCount; i++) {
      let newY;

      if(ys[i]>height) {
        xs[i] = width*Math.random();
        ys[i]=p.random(-rainLengths[i], 0);
      }

      newY = ys[i] + rainLengths[i];

      p.line(xs[i], ys[i], xs[i], newY);

      ys[i] = ys[i] + 100*speed;
    }
    // 泡の描画
    for (let i=0; i<awaCount; i++) {
      for (let k=0; k<vertexCount; k++){
        if (k < vertexCount-1) {
          p.line(
            getAwaX(k, radiuses[i], centerXs[i], purupuruSpeeds[i], rotateSpeeds[i], shapeSpeeds[i]),
            getAwaY(k, radiuses[i], centerYs[i], purupuruSpeeds[i], rotateSpeeds[i], shapeSpeeds[i], trueCircles[i]),
            getAwaX(k+1, radiuses[i], centerXs[i], purupuruSpeeds[i], rotateSpeeds[i], shapeSpeeds[i]),
            getAwaY(k+1, radiuses[i], centerYs[i], purupuruSpeeds[i], rotateSpeeds[i], shapeSpeeds[i], trueCircles[i])
          );
        } else {
          p.line(
            getAwaX(k, radiuses[i], centerXs[i], purupuruSpeeds[i], rotateSpeeds[i], shapeSpeeds[i]),
            getAwaY(k, radiuses[i], centerYs[i], purupuruSpeeds[i], rotateSpeeds[i], shapeSpeeds[i], trueCircles[i]),
            getAwaX(0, radiuses[i], centerXs[i], purupuruSpeeds[i], rotateSpeeds[i], shapeSpeeds[i]),
            getAwaY(0, radiuses[i], centerYs[i], purupuruSpeeds[i], rotateSpeeds[i], shapeSpeeds[i], trueCircles[i])
          );
        }
      }
      if(radiuses[i]<maxRadiuses[i]){
        if(radiuses[i]<1){
          radiuses[i]=1.5;
        }else{
          radiuses[i]*=awaSpeeds[i];
        }
      }else{
        radiuses[i]=0.;
        centerXs[i] = p.random(0, width);
        centerYs[i] = p.random(0, height);
        maxRadiuses[i] = p.random(p.min(width, height)/25, p.min(width, height)/5);
        awaSpeeds[i] = p.random(1.01, 1.06);
        rotateSpeeds[i] = p.random(0.0007, 0.003);
        shapeSpeeds[i] = p.random(0.01, 0.03);
        purupuruSpeeds[i] = p.random(0.001, 0.05);
        trueCircles[i] = p.random(0.9, 1);
      }
    }
    time++;
  }
}

type XY = {
  x: number;
  y: number;
}

const map = (value: number, fromMin: number, fromMax: number, toMin: number, toMax: number) => {
  let ratio = (toMax - toMin) / (fromMax - fromMin);
  return (value - fromMin) * ratio + toMin;
};

const Interface: React.FC = () => {
  // websocket周り
  const privateIp = process.env.REACT_APP_PRIVATE_IP ? process.env.REACT_APP_PRIVATE_IP : 'localhost'
  const socketUrl = `ws://${privateIp}:9001`
  const { sendJsonMessage, lastMessage, readyState } = useWebSocket(
    socketUrl, {
      shouldReconnect: (closeEvent) => true,
      onClose: () => {
        // 
      },
    }
  );
  const connectionStatus = {
    [ReadyState.CONNECTING]: 'Connecting',
    [ReadyState.OPEN]: 'Open',
    [ReadyState.CLOSING]: 'Closing',
    [ReadyState.CLOSED]: 'Closed',
    [ReadyState.UNINSTANTIATED]: 'Uninstantiated',
  }[readyState];
  // ドラッグ&ドロップ周り
  const nodeRef1 = useRef(null);
  const nodeRef2 = useRef(null);
  const nodeRef3 = useRef(null);

  // サイズ調整
  const width = document.documentElement.clientWidth;
  const height = document.documentElement.clientHeight;
  const cageWidth = Math.min(width, height) * 0.7;
  const iconSize = Math.min(cageWidth*0.15, 60);
  const minX = -cageWidth/2;
  const maxX = cageWidth/2 - iconSize;
  const minY = 0;
  const maxY = cageWidth - iconSize;
  const muteZoneHeight = cageWidth*0.4;

  // stateたち
  const [connectionId, setConnectionId] = useState('');
  const [sliderOn, setSliderOn] = useState(true);
  const [rainValue, setRainValue] = useState(0);
  const [pondValue, setPondValue] = useState(0);
  const [roadValue, setRoadValue] = useState(0);
  const [isDrag1, setIsDrag1] = useState(false);
  const [isDrag2, setIsDrag2] = useState(false);
  const [isDrag3, setIsDrag3] = useState(false);
  const [isDoveMute, setIsDoveMute] = useState(false);
  const [isBird2Mute, setIsBird2Mute] = useState(false);
  const [isSynthMute, setIsSynthMute] = useState(false);
  const [doveXY, setDoveXY] = useState<XY>({x: -cageWidth/2, y: 0})
  const [bird2XY, setBird2XY] = useState<XY>({x: cageWidth/2 - iconSize, y: 0})
  const [synthXY, setSynthXY] = useState<XY>({x: cageWidth/2 - iconSize, y: cageWidth - iconSize})
  const [speed, setspeed] = useState(1.5);
  const [pause, setPause] = useState(false);
  const [clear, setClear] = useState(false);
  const handleRainChange = (event: Event, value: number | number[], activeThumb: number) => {
    setRainValue(value as number);
    sendJsonMessage({"type":"rain","value":value as number / 100});
  };
  const handlePondChange = (event: Event, value: number | number[], activeThumb: number) => {
    setPondValue(value as number);
    sendJsonMessage({"type":"pond","value":value as number / 100});
  };
  const handleRoadChange = (event: Event, value: number | number[], activeThumb: number) => {
    setRoadValue(value as number);
    sendJsonMessage({"type":"road","value":value as number / 100});
  }
  const handleDrag1 = (event: any, data: any) => {
    if (data.x>minX && data.x<maxX && data.y>minY && data.y<maxY+muteZoneHeight){
      setDoveXY({x: data.x, y: data.y});
      let yNormed = map(data.y, minY, maxY, 0, 1);
      let isMute = false;
      if (yNormed - 1 > 0.5*muteZoneHeight/cageWidth) {
        setIsDoveMute(true);
        isMute = true;
      } else {
        setIsDoveMute(false);
        isMute = false;
      }
      sendJsonMessage({"type":"dove","x": map(data.x, minX, maxX, 0, 1),"y": map(data.y, minY, maxY, 0, 1),"isMute": isMute ? 1 : 0, "value": 1});
    }
  }
  const handleDrag2 = (event: any, data: any) => {
    if (data.x>minX && data.x<maxX && data.y>minY && data.y<maxY+muteZoneHeight){
      setBird2XY({x: data.x, y: data.y});
      let yNormed = map(data.y, minY, maxY, 0, 1);
      let isMute = false;
      if (yNormed - 1 > 0.5*muteZoneHeight/cageWidth) {
        setIsBird2Mute(true);
        isMute = true;
      } else {
        setIsBird2Mute(false);
        isMute = false;
      }
      sendJsonMessage({"type":"bird2","x": map(data.x, minX, maxX, 0, 1),"y": map(data.y, minY, maxY, 0, 1),"isMute": isMute ? 1 : 0, "value": 1});
    }
  }
  const handleDrag3 = (event: any, data: any) => {
    if (data.x>minX && data.x<maxX && data.y>minY && data.y<maxY+muteZoneHeight){
      setSynthXY({x: data.x, y: data.y});
      let yNormed = map(data.y, minY, maxY, 0, 1);
      let isMute = false;
      if (yNormed - 1 > 0.5*muteZoneHeight/cageWidth) {
        setIsSynthMute(true);
        isMute = true;
      } else {
        setIsSynthMute(false);
        isMute = false;
      }
      sendJsonMessage({"type":"synth","x": map(data.x, minX, maxX, 0, 1),"y": yNormed,"isMute": isMute ? 1 : 0, "value": 1});
    }
  }
  useEffect(() => {
    const preventDefault = (e: any) => e.preventDefault();
    if (isDrag1 || isDrag2 || isDrag3) {
      document.addEventListener('touchmove', preventDefault, {passive: false});
    } else {
      document.removeEventListener('touchmove', preventDefault, false);
    }
    return () => document.removeEventListener('touchmove', preventDefault, false);
  }, [isDrag1, isDrag2, isDrag3])
  useEffect(() => {
    sendJsonMessage({"type":"access"});
  }, [])
  useEffect(() => {
    if (lastMessage) {
      const dataParsed = JSON.parse(lastMessage.data);
      if (dataParsed.type==='access') {
        setConnectionId(dataParsed.connectionId);
      }
      if (dataParsed.type==='rain') {
        setRainValue(dataParsed['value']*100);
      }
      if (dataParsed.type==='pond') {
        setPondValue(dataParsed['value']*100);
      }
      if (dataParsed.type==='road') {
        setRoadValue(dataParsed['value']*100);
      }
      if (dataParsed.type==='dove' && !isDrag1) {
        setDoveXY({x: map(dataParsed['x'], 0, 1, minX, maxX), y: map(dataParsed['y'], 0, 1, minY, maxY)});
        setIsDoveMute(dataParsed['isMute']);
      }
      if (dataParsed.type==='bird2' && !isDrag2) {
        console.log('setBird2XY')
        setBird2XY({x: map(dataParsed['x'], 0, 1, minX, maxX), y: map(dataParsed['y'], 0, 1, minY, maxY)});
        setIsBird2Mute(dataParsed['isMute']);
      }
      if (dataParsed.type==='synth' && !isDrag3) {
        setSynthXY({x: map(dataParsed['x'], 0, 1, minX, maxX), y: map(dataParsed['y'], 0, 1, minY, maxY)});
        setIsSynthMute(dataParsed['isMute']);
      }
    }
  }, [lastMessage])
  return (
    <div>
      <div style={{position: 'relative', width: '100%'}}>
        <div style={{position: 'absolute'}}>
          <ReactP5Wrapper sketch={sketch} speed={speed} pause={pause} clear={clear} rainFall={rainValue/100} underWater={pondValue/100}></ReactP5Wrapper>
        </div>
      </div>
      <div style={{padding: '10px'}}>
        <div style={{position: 'relative', width: '100%'}}>
          <div style={{position: 'absolute', left: '10px'}}>
            <span style={{fontSize: '10pt', color: 'red'}}>{connectionStatus==='Open' ? '': '接続が切れました。リロードしてください。'}</span>
          </div>
          <div style={{position: 'absolute', right: '10px'}}>
            <span style={{fontSize: '10pt'}}>connectionId: </span>
            {connectionId}
          </div>
        </div>
        <Box sx={{ width: '100%', paddingTop: '20px' }}>
          <Grid container spacing={2} alignItems="center" style={{width: '450px', maxWidth: '50%', paddingTop: '5px', paddingBottom: '5px'}}>
            <Grid item>
              <BsCloudRainHeavy size={`2em`} color={'inherit'}/>
            </Grid>
            <Grid item xs>
              <Slider value={rainValue} onChange={handleRainChange} disabled={!sliderOn}/>
            </Grid>
          </Grid>
          <Grid container spacing={2} alignItems="center" style={{width: '900px', maxWidth: '100%', paddingTop: '5px', paddingBottom: '5px'}}>
            <Grid item>
              <MdOutlineBubbleChart size={`2em`} color={'inherit'}/>
            </Grid>
            <Grid item xs>
              <Slider value={pondValue} onChange={handlePondChange} disabled={!sliderOn}/>
            </Grid>
            <Grid item>
              <GiModernCity size={`2em`} color={'inherit'}/>
            </Grid>
            <Grid item xs>
              <Slider value={roadValue} onChange={handleRoadChange} disabled={!sliderOn}/>
            </Grid>
          </Grid>
        </Box>
        <Grid container justifyContent='center' style={{width: '100%', height: cageWidth, position: 'relative', padding: '20px'}}>
          <div style={{
            position: 'absolute',
            border: '1px solid #000000',
            width: cageWidth,
            height: cageWidth,
          }}/>
          <div style={{
            position: 'absolute',
            borderBottom: '1px solid #000000',
            borderLeft: '1px solid #000000',
            borderRight: '1px solid #000000',
            backgroundColor: 'rgb(240, 240, 240)',
            top: cageWidth+20,
            width: cageWidth,
            height: muteZoneHeight,
            zIndex: -1,
          }}/>
          <div style={{
            position: 'absolute',
            fontSize: 0.7*iconSize,
            top: cageWidth+muteZoneHeight/2+20-0.7*iconSize/2,
            color: '#ccc',
          }}>
            <BiVolumeMute/>
          </div>
          <Draggable
            position={{x: doveXY.x, y: doveXY.y}}
            nodeRef={nodeRef1}
            onStart={()=>{setIsDrag1(true)}}
            onStop={()=>{setIsDrag1(false)}}
            onDrag={handleDrag1}
            scale={1}
            handle='b'>
            <div ref={nodeRef1} style={{ position: 'absolute', fontSize: iconSize, cursor: 'pointer', width: '0' }}>
              <b><FaDove color={isDoveMute ? '#999999' : 'inherit'}/></b>
            </div>
          </Draggable>
          <Draggable
            position={{x: bird2XY.x, y: bird2XY.y}}
            nodeRef={nodeRef2}
            onStart={()=>{setIsDrag2(true)}}
            onStop={()=>{setIsDrag2(false)}}
            onDrag={handleDrag2}
            scale={1}
            handle='b'>
            <div ref={nodeRef2} style={{ position: 'absolute', fontSize: iconSize, cursor: 'pointer', width: '0' }}>
              <b><GiHummingbird color={isBird2Mute ? '#999999' : 'inherit'}/></b>
            </div>
          </Draggable>
          <Draggable
            position={{x: synthXY.x, y: synthXY.y}}
            nodeRef={nodeRef3}
            onStart={()=>{setIsDrag3(true)}}
            onStop={()=>{setIsDrag3(false)}}
            onDrag={handleDrag3}
            scale={1}
            handle='b'>
            <div ref={nodeRef3} style={{ position: 'absolute', fontSize: iconSize, cursor: 'pointer', width: '0', textAlign: 'center' }}>
              <b><BsSoundwave color={isSynthMute ? '#999999' : 'inherit'}/></b>
            </div>
          </Draggable>
        </Grid>
      </div>
    </div>
  )
}

const App: React.FC = () => {
  return (
    <Interface/>
  )
}

export default App;
